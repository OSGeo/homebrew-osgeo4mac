class QtMysql < Formula
  homepage "http://qt-project.org/"
  # 15 KB, stripped down archive of just what's needed to compile driver
  url "http://qgis.dakotacarto.com/osgeo4mac/qt-4.8.6-mysql-driver.tar.gz"
  sha1 "a45cc5c766b28c6ae276d79d26b4470a67d03478"
  # 241.5 MB, if downloading full source

  depends_on "qt"
  depends_on :mysql

  def install
    ENV.deparallelize
    cd "src/plugins/sqldrivers/mysql" do
      args = %W[-spec]
      # On Mavericks we want to target libc++, this requires a unsupported/macx-clang-libc++ flag
      if ENV.compiler == :clang and MacOS.version >= :mavericks
        args << "unsupported/macx-clang-libc++"
      else
        args << "macx-g++"
      end
      mysql = Formula["mysql"]
      args << %Q[INCLUDEPATH+="#{mysql.include}/mysql"]
      args << %Q[LIBS+="#{mysql.lib}/libmysqlclient_r.a"]
      args << %Q[LIBS+="-L#{Formula["openssl"].opt_lib}"]
      args << %Q[LIBS+="-lssl"]
      args << %Q[LIBS+="-lcrypto"]
      args << "mysql.pro"

      system "#{HOMEBREW_PREFIX}/bin/qmake", *args
      system "make", "release"
      system "make", "release-install"
    end
  end
end
