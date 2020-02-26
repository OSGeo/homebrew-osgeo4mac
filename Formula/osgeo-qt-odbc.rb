class OsgeoQtOdbc < Formula
  desc "Qt SQL Database Driver - QODBC for Open Database Connectivity (ODBC)"
  homepage "https://doc.qt.io/qt-5/sql-driver.html"
  url "https://download.qt.io/official_releases/qt/5.14/5.14.1/single/qt-everywhere-src-5.14.1.tar.xz"
  sha256 "6f17f488f512b39c2feb57d83a5e0a13dcef32999bea2e2a8f832f54a29badb8"

  revision 2

  head "https://code.qt.io/qt/qt5.git", :branch => "5.14", :shallow => false

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "39d3f151cc9a2725ad9616c34589e430f850c9980b0b0d8f8a67a6efd3a1cc91" => :catalina
    sha256 "39d3f151cc9a2725ad9616c34589e430f850c9980b0b0d8f8a67a6efd3a1cc91" => :mojave
    sha256 "39d3f151cc9a2725ad9616c34589e430f850c9980b0b0d8f8a67a6efd3a1cc91" => :high_sierra
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
  depends_on "unixodbc"
  depends_on :xcode => :build

  def install
    qt_plugins = lib/"qt/plugins"
    (qt_plugins/"sqldrivers").mkpath

    chdir "#{buildpath}/qtbase/src/plugins/sqldrivers" do
      system "#{Formula["qt"].opt_bin}/qmake", "--", "ODBC_PREFIX=#{Formula["unixodbc"].opt_prefix}"
      system "make"

      # copy libqsqlodbc.dylib
      # libqsqlite.dylib from qt
      cp_r "#{buildpath}/qtbase/src/plugins/sqldrivers/plugins/sqldrivers/libqsqlodbc.dylib", "#{lib}/qt/plugins/sqldrivers/"
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
      QCoreApplication::exit(!QSqlDatabase::isDriverAvailable("QODBC"));
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
