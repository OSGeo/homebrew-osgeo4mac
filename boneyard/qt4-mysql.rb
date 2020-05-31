class NoQt4MysqlAlreadyRequirement < Requirement
  fatal true
  satisfy(:build_env => false) { !(Formula["qt-4"].prefix/"plugins/sqldrivers/libqsqlmysql.dylib").exist? }

  def message; <<~EOS
    Qt5 formula already has QtWebKit installed (e.g. built `--with-webkit`)
  EOS
  end
end

class Qt4Mysql < Formula
  desc "MySQL database plugin for Qt 4"
  homepage "http://qt-project.org/"
  # stripped down archive of just what's needed to compile driver
  url "https://osgeo4mac.s3.amazonaws.com/src/qt-4.8.7-mysql-driver.tar.gz"
  sha256 "fd542bb8502308e615aef68c76727091786cdd02f298e5b6e0c168d2ee49be85"

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    sha256 "a32644c5b499c448eb426d19bcc9276f33f377cd199010946b1f85fa83dcb788" => :sierra
    sha256 "a32644c5b499c448eb426d19bcc9276f33f377cd199010946b1f85fa83dcb788" => :high_sierra
  end

  depends_on NoQt4MysqlAlreadyRequirement

  depends_on "mysql" => :build # just needs static client lib and headers
  depends_on "qt-4"
  depends_on "openssl"

  def install
    ENV.deparallelize

    qt_plugins = lib/"qt-4/plugins"
    (qt_plugins/"sqldrivers").mkpath
    inreplace "src/plugins/sqldrivers/qsqldriverbase.pri", "$$[QT_INSTALL_PLUGINS]", qt_plugins.to_s

    cd "src/plugins/sqldrivers/mysql" do
      args = %w[-spec]
      # On Mavericks we want to target libc++, this requires a unsupported/macx-clang-libc++ flag
      if ENV.compiler == :clang && MacOS.version >= :mavericks
        args << "unsupported/macx-clang-libc++"
      else
        args << "macx-g++"
      end
      mysql = Formula["mysql"]
      args << %Q(INCLUDEPATH+="#{mysql.include}/mysql")
      args << %Q(LIBS+="#{mysql.lib}/libmysqlclient.a")
      args << %Q(LIBS+="-L#{Formula["openssl"].opt_lib}")
      args << 'LIBS+="-lssl"'
      args << 'LIBS+="-lcrypto"'
      args << "mysql.pro"

      system "#{Formula["qt-4"].opt_bin}/qmake", *args
      system "make", "release"
      system "make", "release-install"
    end
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
      QCoreApplication::addLibraryPath("#{HOMEBREW_PREFIX}/lib/qt-4/plugins");
      QCoreApplication::addLibraryPath("#{lib}/qt-4/plugins");
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
      system Formula["qt-4"].bin/"qmake", "hello.pro"
      system "make"
      assert_predicate testpath/"client.o", :exist?
      assert_predicate testpath/"moc_client.o", :exist?
      assert_predicate testpath/"main.o", :exist?
      assert_predicate testpath/"hello", :exist?
      system "./hello"
    end
  end
end
