require 'formula'

class QtMysql < Formula
  homepage 'http://qt-project.org/'
  # 15 KB, stripped down archive of just what's needed to compile driver
  url 'http://qgis.dakotacarto.com/osgeo4mac/qt-4.8.5-mysql-driver.tar.gz'
  sha1 '2aa4651510b6974c0c129cfc673b88c7f8dbeeb2'
  # 241.5 MB, if downloading full source
  # url 'http://download.qt-project.org/official_releases/qt/4.8/4.8.5/qt-everywhere-opensource-src-4.8.5.tar.gz'
  # sha1 '745f9ebf091696c0d5403ce691dc28c039d77b9e'

  depends_on 'qt'
  depends_on :mysql

  def install
    cd 'src/plugins/sqldrivers/mysql' do
      mysql = Formula.factory('mysql')
      system "#{HOMEBREW_PREFIX}/bin/qmake -spec macx-g++ \"INCLUDEPATH+=#{mysql.include}/mysql\" \"LIBS+=#{mysql.lib}/libmysqlclient_r.a -lz\" mysql.pro"
      system 'make release'
      system 'make release-install'
    end
  end
end
