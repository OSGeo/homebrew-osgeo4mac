#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
/***************************************************************************
 OSGeo4Mac Python script for generating CMake option string for use in Qt
 Creator with dev builds and installs of QGIS when built off dependencies
 from Homebrew project
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
import re
import sys
import subprocess
from collections import OrderedDict
import argparse

HOMEBREW_PREFIX = \
    subprocess.run(["brew", "--prefix"],
                   stdout=subprocess.PIPE).stdout.decode('UTF-8').strip()

def cellar_version(pkg, hb):
    try:
        cellar_pth = os.readlink('{0}/opt/{1}'.format(hb, pkg))
        return cellar_pth.split('/')[-1]
    except (OSError, IndexError):
        return ''

def cmake_opts(qi, hb, ver):
    # IMPORTANT: mulit-path options need the CMake list semicolon (;) delimiter,
    #            NOT the environment variable path list colon (:) separator

    # set CMAKE_PREFIX_PATH for keg-only installs, and HOMEBREW_PREFIX

    cm_opts = OrderedDict([
        ('CMAKE_INSTALL_PREFIX:PATH', qi),
        ('CMAKE_PREFIX_PATH:INTERNAL',
            '"{hb}/opt/qt5;{hb}/opt/qt5-webkit;'
            '{hb}/opt/libxml2;{hb}/opt/expat;'
            '{hb}/opt/bison;{hb}/opt/flex;'
            '{hb}/opt/sqlite;{hb}/opt/gdal2;'
            '{hb}"'),
        ('CMAKE_BUILD_TYPE:STRING', 'RelWithDebInfo'),
        ('CMAKE_FIND_FRAMEWORK:STRING', 'LAST'),
        ('QT_QMAKE_EXECUTABLE:FILEPATH', '{hb}/opt/qt5/bin/qmake'),

        ('CXX_EXTRA_FLAGS:STRING', ''),
        ('DISABLE_DEPRECATED:BOOL', 'FALSE'),
        ('ENABLE_COVERAGE:BOOL', 'FALSE'),
        ('ENABLE_MODELTEST:BOOL', 'FALSE'),
        ('ENABLE_MSSQLTEST:BOOL', 'FALSE'),
        ('ENABLE_ORACLETEST:BOOL', 'FALSE'),
        ('ENABLE_PGTEST:BOOL', 'FALSE'),
        ('ENABLE_TESTS:BOOL', 'TRUE'),
        ('GENERATE_COVERAGE_DOCS:BOOL', 'FALSE'),
        ('PEDANTIC:BOOL', 'TRUE'),

        ('GDAL_LIBRARY:FILEPATH', '{hb}/opt/gdal2/lib/libgdal.dylib'),
        ('GDAL_CONFIG:FILEPATH', '{hb}/opt/gdal2/bin/gdal-config'),
        ('GEOS_LIBRARY:FILEPATH', '{hb}/opt/geos/lib/libgeos_c.dylib'),
        ('GSL_CONFIG:FILEPATH', '{hb}/opt/gsl/bin/gsl-config'),
        ('GSL_INCLUDE_DIR:PATH', '{hb}/opt/gsl/include'),
        ('GSL_LIBRARIES:STRING', '-L{hb}/opt/gsl/lib -lgsl -lgslcblas'),
        ('POSTGRES_CONFIG:FILEPATH', '{hb}/bin/pg_config'),

        ('WITH_GRASS7:BOOL', 'TRUE'),
        ('GRASS_PREFIX7:PATH', '{hb}/opt/grass7/grass-base'),

        ('WITH_APIDOC:BOOL', 'FALSE'),
        ('WITH_ASTYLE:BOOL', 'TRUE'),
        ('WITH_CUSTOM_WIDGETS:BOOL', 'TRUE'),
        ('WITH_GLOBE:BOOL', 'FALSE'),
        ('WITH_GRASS:BOOL', 'FALSE'),
        ('WITH_INTERNAL_QWTPOLAR:BOOL', 'FALSE'),
        ('WITH_ORACLE:BOOL', 'FALSE'),
        ('WITH_PY_COMPILE:BOOL', 'FALSE'),
        ('WITH_PYSPATIALITE:BOOL', 'FALSE'),
        ('WITH_QSCIAPI:BOOL', 'FALSE'),
        ('WITH_QSPATIALITE:BOOL', 'FALSE'),
        ('WITH_QTWEBKIT:BOOL', 'TRUE'),
        ('WITH_QWTPOLAR:BOOL', 'TRUE'),
        ('WITH_SERVER:BOOL', 'TRUE'),
        ('WITH_STAGED_PLUGINS:BOOL', 'TRUE'),

        ('QGIS_MACAPP_BUNDLE:STRING', '0')
    ])

    # Supplemental
    #

    if os.path.exists(hb + '/Frameworks/Python.framework/Versions/2.7'):
        cm_opts['PYTHON_EXECUTABLE'] = '{hb}/bin/python'

    return cm_opts


def arg_parser():
    parser = argparse.ArgumentParser(
        description="""\
            Script for generating CMake option string for use in Qt Creator with
            dev builds and installs of QGIS when built off dependencies from
            Homebrew.
            """
    )
    parser.add_argument(
        '-p', '--homebrew-prefix', dest='hb',
        metavar='homebrew_prefix',
        help='homebrew prefix path, or set HOMEBREW_PREFIX'
    )
    parser.add_argument(
        'qs', metavar='qgis-src-dir',
        help='QGIS source directory'
    )
    parser.add_argument(
        'qi', metavar='qgis-install-dir',
        help='QGIS install directory'
    )
    return parser


def main():
    # get defined args
    args = arg_parser().parse_args()

    qs = os.path.realpath(args.qs)
    if not os.path.isabs(qs) or not os.path.exists(qs):
        print 'QGIS source directory not resolved to existing absolute path.'
        sys.exit(1)

    # get QGIS version
    s = ''
    with file(os.path.join(qs, 'CMakeLists.txt')) as f:
        for _ in range(5):
            s += f.readline()
    # print s
    p = re.compile(r'CPACK_PACKAGE_VERSION_..... "(..?)"')
    ver = p.findall(s)
    print ver

    if not ver:
        print 'QGIS version could not be resolved.'
        sys.exit(1)

    if len(ver) != 3:
        print 'QGIS version\'s major.minor.patch could not be resolved.'
        sys.exit(1)

    qi = os.path.realpath(args.qi)
    if not os.path.isabs(qi) or not os.path.exists(qi):
        print 'QGIS install directory not resolved to existing absolute path.'
        sys.exit(1)

    # generate list of environment variables
    hb_prefix = HOMEBREW_PREFIX
    if 'HOMEBREW_PREFIX' in os.environ:
        hb_prefix = os.environ['HOMEBREW_PREFIX']
    hb = os.path.realpath(args.hb) if args.hb else hb_prefix
    if not os.path.isabs(hb) or not os.path.exists(hb):
        print 'HOMEBREW_PREFIX not resolved to existing absolute path.'
        sys.exit(1)

    # generate cmake options
    cm_opts = cmake_opts(qi, hb, ver)

    cm_opts_s = args.qs
    for k, v in cm_opts.iteritems():
        cm_opts_s += ' -D{0}={1}'.format(k, v.format(hb=hb))

    os.system("echo '{0}' | pbcopy".format(cm_opts_s))
    print "\nThe following has been copied to the clipboard:\n"
    print cm_opts_s


if __name__ == '__main__':
    main()
    sys.exit(0)
