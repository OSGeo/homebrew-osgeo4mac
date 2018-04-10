class Qt4Oracle < Formula
  desc "Oracle database plugin for Qt 4"
  homepage "http://qt-project.org/"
  # stripped down archive of just what's needed to compile driver
  url "https://osgeo4mac.s3.amazonaws.com/src/qt-4.8.7-oracle-driver.tar.gz"
  sha256 "72714836bebc58c7d0944110fef956ba085c714c7e81f00da287cdeedcbc231b"

  depends_on "qt-4"
  depends_on "oracle-client-sdk"

  def oracle_env_vars
    oci = Formula["oracle-client-sdk"]
    tab = Tab.for_formula(self)
    opts = tab.used_options
    oci_env_vars = {
      :ORACLE_HOME => oci.opt_prefix,
      :OCI_LIB => oci.opt_lib,
      :TNS_ADMIN => oci.opt_prefix/"network/admin",
    }
    oci_env_vars[:NLS_LANG] = "AMERICAN_AMERICA.UTF8" unless opts.include?("with-basic")
    oci_env_vars
  end

  def install
    ENV.deparallelize

    qt_plugins = lib/"qt-4/plugins"
    (qt_plugins/"sqldrivers").mkpath
    inreplace "src/plugins/sqldrivers/qsqldriverbase.pri", "$$[QT_INSTALL_PLUGINS]", qt_plugins.to_s

    sql_drivers = "#{buildpath}/src/sql/drivers"
    inreplace "#{sql_drivers}/oci/qsql_oci.h", "<QtSql/private/qsqlcachedresult_p.h>", '"qsqlcachedresult_p.h"'

    cd "src/plugins/sqldrivers/oci" do
      args = %w[-spec]
      # On Mavericks we want to target libc++, this requires a unsupported/macx-clang-libc++ flag
      if ENV.compiler == :clang && MacOS.version >= :mavericks
        args << "unsupported/macx-clang-libc++"
      else
        args << "macx-g++"
      end
      args << %Q(INCLUDEPATH+="#{sql_drivers}/kernel")
      oci = Formula["oracle-client-sdk"]
      args << %Q(INCLUDEPATH+="#{oci.include}/oci")
      args << %Q(LIBS+="-L#{oci.opt_lib}")
      args << "oci.pro"

      # args << %Q(QMAKE_LFLAGS+="-Wl,-flat_namespace,-U,_environ")
      system "#{Formula["qt-4"].opt_bin}/qmake", *args
      system "make", "release"
      system "make", "release-install"
    end
  end

  def caveats
    s = <<~EOS
    Oracle client SDK environ:
    EOS
    oracle_env_vars.each { |k, v| s += "  #{k}=#{v}\n" }
    s += "\n"
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
      QCoreApplication::exit(!QSqlDatabase::isDriverAvailable("QOCI"));
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
