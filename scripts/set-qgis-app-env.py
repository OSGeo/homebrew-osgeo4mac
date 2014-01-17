#!/usr/bin/env python

import os
import sys
import argparse
import subprocess
from collections import OrderedDict

HOME = os.path.expanduser('~')
GRASS_VERSION = '6.4.3'
OSG_VERSION = '3.2.0'
HOMEBREW_PREFIX = '/usr/local'
QGIS_BUILD_DIR = HOME + '/QGIS/github.com/build-osgeo4mac'
QGIS_LOG_DIR = HOME + '/Library/Logs/QGIS'


def env_vars(ap, hb, qb=''):
    options = OrderedDict()
    options['PATH'] = '{hb}/bin:{hb}/sbin:' + os.environ['PATH']

    dyld_path = '{hb}/opt/sqlite/lib:{hb}/opt/libxml2/lib:{hb}/lib'
    if qb and os.path.exists(qb) and os.path.realpath(qb) in ap:
        dyld_path += '{qb}/output/lib:{qb}/PlugIns/qgis:'

    # if QGIS_MACAPP_BUNDLE == 0, find the right frameworks and libs
    if not os.path.exists(ap + '/Contents/Frameworks/QtCore.framework'):
        options['DYLD_FRAMEWORK_PATH'] = \
            '{hb}/Frameworks:/System/Library/Frameworks'
        options['DYLD_VERSIONED_LIBRARY_PATH'] = dyld_path

    # isolate Python setup if Kyngchaos frameworks exist (they bogart sys.path)
    # this keeps /Library/Python/2.7/site-packages from being searched
    if (os.path.exists(hb + '/Frameworks/Python.framework') and
            os.path.exists('/Library/Frameworks/GDAL.framework')):
        options['PYQGIS_STARTUP'] = '{hb}/Library/Taps/dakcarto-osgeo4mac' \
                                    '/enviro/python_startup.py'
        options['PYTHONHOME'] = '{hb}/Frameworks/Python.framework/Versions/2.7'

    options['PYTHONPATH'] = '{hb}/lib/python2.7/site-packages'
    options['GDAL_DRIVER_PATH'] = '{hb}/lib/gdalplugins'
    options['QGIS_LOG_FILE'] = '{ql}/qgis.log'

    return options


def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument("app", help="path to app bundle")
    parser.add_argument("-p", "--homebrew-prefix", dest="hb",
                        help="homebrew prefix path, or set HOMEBREW_PREFIX")
    parser.add_argument("-b", "--build-dir", dest="qb",
                        help="QGIS build directory")
    args = parser.parse_args()

    ap = os.path.realpath(args.app)
    if not os.path.isabs(ap) or not os.path.exists(ap):
        print 'Application can not be resolved to an existing absolute path.'
        sys.exit(1)

    plist = ap + '/Contents/Info.plist'
    if not os.path.exists(plist):
        print 'Application Info.plist not found.'
        sys.exit(1)

    # generate list of environment variables
    hb_prefix = HOMEBREW_PREFIX
    if 'HOMEBREW_PREFIX' in os.environ:
        hb_prefix = os.environ['HOMEBREW_PREFIX']
    hb = args.hb if args.hb else hb_prefix

    qb = args.qb if args.qb else ''

    evars = env_vars(ap, hb, qb)
    opts_s = ''
    for k, v in evars.iteritems():
        opts_s += "{0}={1}\n".format(k, v.format(hb=hb,
                                                  grsv=GRASS_VERSION,
                                                  osgv=OSG_VERSION,
                                                  qb=QGIS_BUILD_DIR,
                                                  ql=QGIS_LOG_DIR))

    print opts_s

    # set bundle identifier, so package installers don't accidentally install
    # updates into bundle

    # subprocess.call(["/usr/libexec/PlistBuddy", "-c"])

if __name__ == "__main__":
    main(sys.argv[1:])
