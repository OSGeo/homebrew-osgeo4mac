#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
/***************************************************************************
 OSGeo4Mac Python script for generating CMake option string for use in Qt
 Creator with dev builds and installs of QGIS when built off dependencies
 from homebrew-osgeo4mac tap
                              -------------------
        begin    : January 2014
        copyright: (C) 2014 Larry Shaffer
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
from collections import OrderedDict
import argparse

GRASS_VERSION = '6.4.4'
GRASS7_VERSION = '7.0.3'
OSG_VERSION = '3.4.0'
HOMEBREW_PREFIX = '/usr/local'  # default for Homebrew


def cmake_opts(qi, hb, ver):
    # define versions of CMake option changes
    lt27 = int(ver[0]) <= 2 and int(ver[1]) < 7
    w_server = 'WITH_MAPSERVER' if lt27 else 'WITH_SERVER'

    # ensure libintl.h can be found in gettext for grass
    cxx_flags = "-I{hb}/opt/gettext/include"
    if 'CXXFLAGS' in os.environ:
        cxx_flags += " " + os.environ['CXXFLAGS']

    # search Homebrew's Frameworks directory before those in /Library or /System
    ld_flags = "-F{hb}/Frameworks"
    if 'LDFLAGS' in os.environ:
        ld_flags += " " + os.environ['LDFLAGS']

    # IMPORTANT: mulit-path options need the CMake list semicolon (;) delimiter,
    #            NOT the environment variable path list colon (:) separator

    # set CMAKE_PREFIX_PATH for keg-only installs, and HOMEBREW_PREFIX

    cm_opts = OrderedDict([
        ('CMAKE_INSTALL_PREFIX', qi),
        ('CMAKE_PREFIX_PATH', '"{hb}/opt/libxml2;{hb}/opt/expat;'
                              '{hb}/opt/gettext;{hb}/opt/sqlite;'
                              '{hb}/opt/gdal-20;'
                              '{hb}"'),
        ('CMAKE_FRAMEWORK_PATH', '"{hb}/opt/qwt/lib;{hb}/opt/qwtpolar/lib"'),
        ('CMAKE_BUILD_TYPE', 'RelWithDebInfo'),
        ('CMAKE_FIND_FRAMEWORK', 'LAST'),
        ('CMAKE_CXX_FLAGS', '"' + cxx_flags + '"'),
        ('CMAKE_EXE_LINKER_FLAGS', '"' + ld_flags + '"'),
        ('CMAKE_MODULE_LINKER_FLAGS', '"' + ld_flags + '"'),
        ('CMAKE_SHARED_LINKER_FLAGS', '"' + ld_flags + '"'),
        ('CXX_EXTRA_FLAGS', '"-Wno-inconsistent-missing-override '
                            '-Wno-unused-private-field '
                            '-Wno-deprecated-register"'),
        ('BISON_EXECUTABLE', '{hb}/opt/bison/bin/bison'),
        ('QT_QMAKE_EXECUTABLE', '{hb}/bin/qmake'),
        ('SUPPRESS_QT_WARNINGS', 'TRUE'),
        ('GITCOMMAND', '{hb}/bin/git'),
        ('ENABLE_TESTS', 'TRUE'),
        ('ENABLE_MODELTEST', 'TRUE'),
        ('WITH_ASTYLE', 'TRUE'),
        ('WITH_PYSPATIALITE', 'FALSE'),
        ('WITH_QWTPOLAR', 'TRUE'),
        ('WITH_INTERNAL_QWTPOLAR', 'FALSE'),
        (w_server, 'TRUE'),
        ('WITH_STAGED_PLUGINS', 'FALSE'),
        ('WITH_PY_COMPILE', 'TRUE'),
        ('WITH_APIDOC', 'FALSE'),
        ('WITH_QSCIAPI', 'FALSE'),
        ('QSCI_SIP_DIR', '{hb}/opt/qscintilla2/share/sip'),
        ('GDAL_CONFIG', '{hb}/opt/gdal-20/bin/gdal-config'),
        ('POSTGRES_CONFIG', '{hb}/bin/pg_config'),
        ('WITH_QSPATIALITE', 'TRUE'),
        ('WITH_GRASS', 'FALSE'),
        ('WITH_GRASS7', 'TRUE'),
        ('GRASS_PREFIX7', '{hb}/opt/grass-70/grass-' + GRASS7_VERSION),
        ('WITH_GLOBE', 'FALSE'),
        ('WITH_ORACLE', 'FALSE'),
        ('QGIS_MACAPP_BUNDLE', '0')
    ])

    # ('CMAKE_FRAMEWORK_PATH', '""')

    # Supplemental

    # ('OSG_DIR', '{hb}'),
    # ('OSGEARTH_DIR', '{hb}'),
    # ('OSG_PLUGINS_PATH', '{hb}/lib/osgPlugins-' + OSG_VERSION),

    # ('GRASS_PREFIX', '{hb}/opt/grass-64/grass-' + GRASS_VERSION),

    # ('OCI_INCLUDE_DIR', '{hb}/opt/oracle-client-sdk/sdk/include'),
    # ('OCI_LIBRARY', '{hb}/lib/libclntsh.dylib'),

    # These should be found automatically now...
    # ('SQLITE3_INCLUDE_DIR', '{hb}/opt/sqlite/include'),
    # ('SQLITE3_LIBRARY', '{hb}/opt/sqlite/lib/libsqlite3.dylib'),
    # ('QSCINTILLA_INCLUDE_DIR', '{hb}/opt/qscintilla2/include/Qsci'),
    # ('QSCINTILLA_LIBRARY', '{hb}/opt/qscintilla2/lib/libqscintilla2.dylib'),
    # ('QWT_LIBRARY', '{hb}/opt/qwt/lib/qwt.framework/qwt'),
    # ('QWT_INCLUDE_DIR', '{hb}/opt/qwt/lib/qwt.framework/Headers'),
    # ('QWTPOLAR_LIBRARY',
    #  '{hb}/opt/qwtpolar/lib/qwtpolar.framework/qwt'),
    # ('QWTPOLAR_INCLUDE_DIR',
    #  '{hb}/opt/qwtpolar/lib/qwtpolar.framework/Headers'),
    # ('WITH_INTERNAL_SPATIALITE', 'FALSE'),

    if os.path.exists(hb + '/Frameworks/Python.framework/Versions/2.7'):
        cm_opts['PYTHON_EXECUTABLE'] = '{hb}/bin/python'
        cm_opts['PYTHON_CUSTOM_FRAMEWORK'] = \
            '{hb}/Frameworks/Python.framework/Versions/2.7'

    return cm_opts


def arg_parser():
    parser = argparse.ArgumentParser(
        description="""\
            Script for generating CMake option string for use in Qt Creator with
            dev builds and installs of QGIS when built off dependencies from
            homebrew-osgeo4mac tap.
            """
    )
    parser.add_argument(
        '-p', '--homebrew-prefix', dest='hb',
        metavar='homebrew_prefix',
        help='homebrew prefix path, or set HOMEBREW_PREFIX (/usr/local default)'
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
