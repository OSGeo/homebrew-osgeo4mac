#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
/***************************************************************************
  Python startup script for setting env vars in dev builds/installs of QGIS 3
  when built off dependencies from homebrew
                              -------------------
        begin    : November 2016
        copyright: (C) 2016 Larry Shaffer
        email    : larrys at dakotacarto dot com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
"""

import os
import stat
import sys
import argparse
import subprocess
from collections import OrderedDict

HOME = os.path.expanduser('~')
HOMEBREW_PREFIX = \
    subprocess.run(["brew", "--prefix"],
                   stdout=subprocess.PIPE).stdout.decode('UTF-8').strip()

PY_VER = '{0}.{1}'.format(sys.version_info[0],sys.version_info[1]).strip()
QGIS_LOG_DIR = HOME + '/Library/Logs/QGIS'
QGIS_LOG_FILE = QGIS_LOG_DIR + '/qgis3-dev.log'


def cellar_version(pkg, hb):
    try:
        cellar_pth = os.readlink('{0}/opt/{1}'.format(hb, pkg))
        return cellar_pth.split('/')[-1]
    except (OSError, IndexError):
        return ''


def env_vars(ap, hb, qb='', ql=''):
    options = OrderedDict()
    # will probably generate duplicate paths in PATH
    options['PATH'] = '{hb}/opt/gdal2/bin:' \
                      '{hb}/opt/gdal2-python/bin:{hb}/opt/gdal2-python/libexec/bin:' \
                      '{hb}/opt/qt5/bin:{hb}/opt/qt5-webkit/bin:' \
                      '{hb}/bin:{hb}/sbin:' + os.environ['PATH']
    options['PYTHONPATH'] = '{hb}/opt/gdal2-python/lib/python{pv}/site-packages:' \
                            '{hb}/lib/python{pv}/site-packages'
    options['GDAL_DRIVER_PATH'] = '{hb}/lib/gdalplugins'
    options['GDAL_DATA'] = '{hb}/opt/gdal2/share/gdal'
    options['GRASS_PREFIX'] = '{hb}/opt/grass7/grass-base'
    osg_ver = cellar_version('open-scene-graph', hb)
    if osg_ver:
        options['OSG_LIBRARY_PATH'] = '{hb}/lib/osgPlugins-' + osg_ver
    options['QGIS_LOG_FILE'] = ql

    for k, v in options.items():
        options[k] = v.format(hb=hb, pv=PY_VER)

    return options


def plist_bud(cmd, plist, quiet=False):
    out = open(os.devnull, 'w') if quiet else None
    subprocess.run(['/usr/libexec/PlistBuddy', '-c', cmd, plist],
                   stdout=out, stderr=out)


def arg_parser():
    parser = argparse.ArgumentParser(
        description="""\
            Script embeds Homebrew-prefix-relative environment variables in a
            development QGIS.app bundle in the LSEnvironment entity of the app's
            Info.plist. Running on app bundle from build or install directory,
            or whether Kyngchaos.com or Qt development package installers have
            been used, yields different results. QGIS_LOG_FILE is at (unless
            defined in env var or command option): {0}
            """.format(QGIS_LOG_FILE)
    )
    parser.add_argument('qgis_app_path',
                        help='path to app bundle (relative or absolute)')
    parser.add_argument(
        '-p', '--homebrew-prefix', dest='hb',
        metavar='homebrew_prefix',
        help='homebrew prefix path, or set HOMEBREW_PREFIX'
    )
    parser.add_argument(
        '-b', '--build-dir', dest='qb',
        metavar='qgis_build_dir',
        help='QGIS build directory'
    )
    parser.add_argument(
        '-l', '--qgis-log', dest='ql',
        metavar='qgis_log_file',
        help='QGIS debug output log file'
    )
    return parser


def main():
    # get defined args
    args = arg_parser().parse_args()

    ap = os.path.realpath(args.qgis_app_path)
    if not os.path.isabs(ap) or not os.path.exists(ap):
        print('Application can not be resolved to an existing absolute path.')
        sys.exit(1)

    # QGIS Browser.app?
    browser = 'Browser.' in ap

    plist = ap + '/Contents/Info.plist'
    if not os.path.exists(plist):
        print('Application Info.plist not found.')
        sys.exit(1)

    # generate list of environment variables
    hb_prefix = HOMEBREW_PREFIX
    if 'HOMEBREW_PREFIX' in os.environ:
        hb_prefix = os.environ['HOMEBREW_PREFIX']
    hb = os.path.realpath(args.hb) if args.hb else hb_prefix
    if not os.path.isabs(hb) or not os.path.exists(hb):
        print('HOMEBREW_PREFIX not resolved to existing absolute path.')
        sys.exit(1)

    q_log = QGIS_LOG_FILE
    if 'QGIS_LOG_FILE' in os.environ:
        q_log = os.environ['QGIS_LOG_FILE']
    ql = os.path.realpath(args.ql) if args.ql else q_log
    try:
        if not os.path.exists(ql):
            if ql == os.path.realpath(QGIS_LOG_FILE):
                # ok to auto-create log's parent directories
                p_dir = os.path.dirname(ql)
                if not os.path.exists(p_dir):
                    os.makedirs(p_dir)
            subprocess.run(['/usr/bin/touch', ql])
    except OSError as e:
        print('Could not create QGIS log file at: {0}'.format(ql))
        print('Create an empty file at the indicated path for logging to work.')
        print("Warning: {0}".format(e), file=sys.stderr)

    qb = os.path.realpath(args.qb) if args.qb else ''
    if qb and (not os.path.isabs(qb) or not os.path.exists(qb)):
        print('QGIS build directory not resolved to existing absolute path.')
        sys.exit(1)

    # write variables to Info.plist
    evars = env_vars(ap, hb, qb, ql)

    # opts_s = ''
    # for k, v in evars.items():
    #     opts_s += '{0}={1}\n'.format(k, v)
    # print(opts_s + '\n')

    # first delete any LSEnvironment setting, ignoring errors
    # CAUTION!: this may not be what you want, if the .app already has
    #           LSEnvironment settings
    plist_bud('Delete :LSEnvironment', plist, quiet=True)

    # re-add the LSEnvironment entry
    plist_bud('Add :LSEnvironment dict', plist)

    # add the variables
    for k, v in evars.items():
        plist_bud("Add :LSEnvironment:{0} string '{1}'".format(k, v), plist)

    # set app HiDPI support
    plist_bud('Delete :NSHighResolutionCapable', plist, quiet=True)
    plist_bud("Add :NSHighResolutionCapable string 'True'", plist)

    # set bundle identifier, so package installers don't accidentally install
    # updates into dev bundles
    app_id = 'qgis'
    app_name = 'QGIS'
    if browser:
        app_id += '-browser'
        app_name += ' Browser'
    plist_bud('Set :CFBundleIdentifier org.qgis.{0}-dev'.format(app_id), plist)

    # update modification date on app bundle, or changes won't take effect
    subprocess.run(['/usr/bin/touch', ap])

    # add environment-wrapped launcher shell script
    wrp_scr = ap + '/Contents/MacOS/{0}.sh'.format(app_id)

    # override vars that need to prepend existing vars
    evars['PATH'] = '{hb}/opt/gdal2/bin:' \
                    '{hb}/opt/gdal2-python/bin:{hb}/opt/gdal2-python/libexec/bin:' \
                    '{hb}/opt/qt5/bin:{hb}/opt/qt5-webkit/bin:' \
                    '{hb}/bin:{hb}/sbin:$PATH'.format(hb=hb)
    evars['PYTHONPATH'] = \
        '{hb}/opt/gdal2-python/lib/python{pv}/site-packages:' \
        '{hb}/lib/python{pv}/site-packages:$PYTHONPATH'.format(hb=hb, pv=PY_VER)

    if os.path.exists(wrp_scr):
        os.remove(wrp_scr)

    with open(wrp_scr, 'a') as f:
        f.write('#!/bin/bash\n\n')

        # get runtime parent directory
        f.write('DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)\n\n')

        # add the variables
        for k, v in evars.items():
            f.write('export {0}={1}\n'.format(k, v))

        f.write('\n"$DIR/{0}" "$@"\n'.format(app_name))

    os.chmod(wrp_scr, stat.S_IRUSR | stat.S_IWUSR | stat.S_IEXEC)

    print('Done setting variables')

if __name__ == '__main__':
    main()
    sys.exit(0)
