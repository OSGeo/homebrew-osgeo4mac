#!/usr/bin/env python

import os
from collections import OrderedDict

HOME = os.path.expanduser('~')
SRC_DIR = HOME + '/QGIS/github.com/QGIS'
INSTALL_PREFIX = HOME + '/QGIS/github.com/QGIS_Apps_osgeo4mac'

HOMEBREW_PREFIX = '/usr/local'
GRASS_VERSION = '6.4.3'
OSG_VERSION = '3.2.0'

opts = OrderedDict([
    ('CMAKE_INSTALL_PREFIX', INSTALL_PREFIX),
    ('CMAKE_BUILD_TYPE', 'RelWithDebInfo'),
    ('CMAKE_FIND_FRAMEWORK', 'LAST'),
    ('CXX_EXTRA_FLAGS', '-Wno-unused-private-field'),
    ('CMAKE_PREFIX_PATH', '{hb}/opt/expat:{hb}/opt/gettext:{hb}'),
    ('BISON_EXECUTABLE', '{hb}/opt/bison/bin/bison'),
    ('QT_QMAKE_EXECUTABLE', '{hb}/bin/qmake'),
    ('GITCOMMAND', '{hb}/bin/git'),
    ('ENABLE_TESTS', 'TRUE'),
    ('WITH_ASTYLE', 'TRUE'),
    ('WITH_INTERNAL_SPATIALITE', 'FALSE'),
    ('WITH_PYSPATIALITE', 'FALSE'),
    ('SQLITE3_INCLUDE_DIR', '{hb}/opt/sqlite/include'),
    ('SQLITE3_LIBRARY', '{hb}/opt/sqlite/lib/libsqlite3.dylib'),
    ('QWT_LIBRARY', '{hb}/opt/qwt/lib/qwt.framework/qwt'),
    ('QWT_INCLUDE_DIR', '{hb}/opt/qwt/lib/qwt.framework/Headers'),
    ('QSCINTILLA_INCLUDE_DIR', '{hb}/opt/qscintilla2/include/Qsci'),
    ('QSCINTILLA_LIBRARY', '{hb}/opt/qscintilla2/lib/libqscintilla2.dylib'),
    ('WITH_INTERNAL_QWTPOLAR', 'FALSE'),
    ('WITH_MAPSERVER', 'TRUE'),
    ('WITH_STAGED_PLUGINS', 'FALSE'),
    ('WITH_PY_COMPILE', 'TRUE'),
    ('WITH_APIDOC', 'FALSE'),
    ('WITH_QSCIAPI', 'FALSE'),
    ('POSTGRESQL_PREFIX', '{hb}'),
    ('POSTGRES_CONFIG', '{hb}/bin/pg_config'),
    ('WITH_GRASS', 'TRUE'),
    ('GRASS_PREFIX', '{hb}/opt/grass/grass-{grsv}'),
    ('WITH_GLOBE', 'TRUE'),
    ('OSG_DIR', '{hb}'),
    ('OSGEARTH_DIR', '{hb}'),
    ('OSG_PLUGINS_PATH', '{hb}/lib/osgPlugins-{osgv}'),
    ('QGIS_MACAPP_BUNDLE', '0')
])

if os.path.exists(HOMEBREW_PREFIX + '/Frameworks/Python.framework'):
    opts['PYTHON_EXECUTABLE'] = '{hb}/bin/python'
    opts['PYTHON_CUSTOM_FRAMEWORK'] = '{hb}/Frameworks/Python.framework'

opts_s = SRC_DIR
for k, v in opts.iteritems():
    opts_s += ' -D{0}={1}'.format(k, v.format(hb=HOMEBREW_PREFIX,
                                              grsv=GRASS_VERSION,
                                              osgv=OSG_VERSION))

os.system('echo {0} | pbcopy'.format(opts_s))
