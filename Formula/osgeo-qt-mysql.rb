class OsgeoQtMysql < Formula
  desc "Qt SQL Database Driver - QMYSQL for MySQL 4 and higher"
  homepage "https://doc.qt.io/qt-5/sql-driver.html"
  url "https://download.qt.io/official_releases/qt/5.13/5.13.0/single/qt-everywhere-src-5.13.0.tar.xz"
  sha256 "2cba31e410e169bd5cdae159f839640e672532a4687ea0f265f686421e0e86d6"

  # revision 1

  head "https://code.qt.io/qt/qt5.git", :branch => "5.12", :shallow => false

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    rebuild 1
    sha256 "f8a741e32bdfdae74891c8cd12e449f929907754e0ab7ccd0aea664a048b2c5b" => :mojave
    sha256 "f8a741e32bdfdae74891c8cd12e449f929907754e0ab7ccd0aea664a048b2c5b" => :high_sierra
    sha256 "136aaaa1dee0b5db7854702d66fbb6f4b8e0e26dea5a87f5992a4f16a87728ec" => :sierra
  end

  depends_on "pkg-config" => :build
  depends_on "libiconv"
  depends_on "gettext"
  depends_on "libxml2"
  depends_on "libxslt"
  depends_on "zlib"
  depends_on "qt"
  depends_on "sqlite"
  depends_on "openssl"
  depends_on "mysql"
  depends_on :xcode => :build

  def install
    qt_plugins = lib/"qt/plugins"
    (qt_plugins/"sqldrivers").mkpath

    chdir "#{buildpath}/qtbase/src/plugins/sqldrivers" do
      system "#{Formula["qt"].opt_bin}/qmake", "--", "MYSQL_PREFIX=#{Formula["mysql"].opt_prefix}"
      system "make"

      # copy libqsqlmysql.dylib
      # libqsqlite.dylib from qt
      cp_r "#{buildpath}/qtbase/src/plugins/sqldrivers/plugins/sqldrivers/libqsqlmysql.dylib", "#{lib}/qt/plugins/sqldrivers/"
    end
  end

  def caveats; <<~EOS
    Plugins generated are linked to the following directory:

      #{HOMEBREW_PREFIX}/lib/qt/plugins/sqldrivers
  EOS
  end

  test do
    (testpath/"hello.pro").write <<~EOS
      QT        += core sql
      QT        -= gui
      TARGET     = hello
      CONFIG    += console
      CONFIG    -= app_bundle
      TEMPLATE   = app
      HEADERS    = client.h
      SOURCES   += client.cpp main.cpp
    EOS

    (testpath/"client.h").write <<~EOS
    #ifndef CLIENT_H
    #define CLIENT_H
    #include <QObject>
    #include <QSqlDatabase>
    #include <QString>
    class Client : public QObject
    {
      Q_OBJECT
    public:
      Client(QObject *parent = 0);
    public slots:
      void checkSqlDriver();
    };
    #endif // CLIENT_H
    EOS

    (testpath/"client.cpp").write <<~EOS
    #include "client.h"
    #include <QCoreApplication>
    #include <QDebug>
    #include <QSqlDatabase>
    #include <QStringList>
    Client::Client(QObject *parent)
      : QObject(parent)
    {
    }
    void Client::checkSqlDriver()
    {
      QCoreApplication::addLibraryPath("#{HOMEBREW_PREFIX}/lib/qt/plugins");
      QCoreApplication::addLibraryPath("#{lib}/qt/plugins");
      qDebug() << "QSqlDatabase::drivers(): " << QSqlDatabase::drivers().join(" ");
      QCoreApplication::exit(!QSqlDatabase::isDriverAvailable("QMYSQL"));
    }
    EOS

    (testpath/"main.cpp").write <<~EOS
      #include <QCoreApplication>
      #include <QDebug>
      #include <QTimer>
      #include "client.h"
      int main(int argc, char *argv[])
      {
        QCoreApplication app(argc, argv);
        Client c(app.instance());
        qDebug() << "Running application";
        QTimer::singleShot(1000, &c, SLOT(checkSqlDriver()));
        return app.exec();
      }
    EOS

    cd testpath do
      system Formula["qt"].bin/"qmake", "hello.pro"
      system "make"
      assert_predicate testpath/"client.o", :exist?
      assert_predicate testpath/"moc_client.o", :exist?
      assert_predicate testpath/"main.o", :exist?
      assert_predicate testpath/"hello", :exist?
      system "./hello"
    end
  end
end
