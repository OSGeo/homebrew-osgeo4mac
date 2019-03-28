class Qt4 < Formula
  desc "Cross-platform application and UI framework"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/archive/qt/4.8/4.8.7/qt-everywhere-opensource-src-4.8.7.tar.gz"
  mirror "http://qt.mirror.constant.com/archive/qt/4.8/4.8.7/qt-everywhere-opensource-src-4.8.7.tar.gz"
  sha256 "e2882295097e47fe089f8ac741a95fef47e0a73a3f3cdf21b56990638f626ea0"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    rebuild 1
    sha256 "b144bc04f10d95c1855ab79d69e0a2905694eb0165907846c8b153fa64ff1f67" => :high_sierra
    sha256 "b144bc04f10d95c1855ab79d69e0a2905694eb0165907846c8b153fa64ff1f67" => :sierra
  end

  # Backport of Qt5 commit to fix the fatal build error with Xcode 7, SDK 10.11.
  # https://code.qt.io/cgit/qt/qtbase.git/commit/?id=b06304e164ba47351fa292662c1e6383c081b5ca
  if MacOS.version >= :el_capitan
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/480b7142c4e2ae07de6028f672695eb927a34875/qt/el-capitan.patch"
      sha256 "c8a0fa819c8012a7cb70e902abb7133fc05235881ce230235d93719c47650c4e"
    end
  end

  keg_only "deprecated in homebrew-core for macOS >= Sierra (10.12)"

  option "with-qt3support", "Build with deprecated Qt3Support module support"
  option "with-docs", "Build documentation"
  option "without-webkit", "Build without QtWebKit module"

  depends_on "openssl"
  depends_on "dbus" => :optional
  depends_on "mysql" => :optional
  depends_on "osgeo-postgresql" => :optional

  # Qt4 is dead upstream. We backported a build fix for 10.11 but do not
  # intend to keep rescuing it forever, including for macOS 10.12. Homebrew will
  # be migrating to Qt5 as widely as possible, which remains supported upstream.
  # depends on MaximumMacOSRequirement => :el_capitan

  deprecated_option "qtdbus" => "with-dbus"
  deprecated_option "with-d-bus" => "with-dbus"

  resource "test-project" do
    url "https://gist.github.com/tdsmith/f55e7e69ae174b5b5a03.git",
        :revision => "6f565390395a0259fa85fdd3a4f1968ebcd1cc7d"
  end

  def install
    if ENV.compiler == :clang && (MacOS::Xcode.version >= "9.0" || MacOS::CLT.version >= "9.0")
      odie <<~EOS
        Compilation not supported with Xcode/CLT 9.0 or higher.
        Use no formula or source-build options and install available bottle.
      EOS
    end

    args = %W[
      -prefix #{prefix}
      -release
      -opensource
      -confirm-license
      -fast
      -system-zlib
      -qt-libtiff
      -qt-libpng
      -qt-libjpeg
      -nomake demos
      -nomake examples
      -cocoa
    ]

    if ENV.compiler == :clang
      args << "-platform"

      if MacOS.version >= :mavericks
        args << "unsupported/macx-clang-libc++"
      else
        args << "unsupported/macx-clang"
      end
    end

    # Phonon is broken on macOS 10.12+ and Xcode 8+ due to QTKit.framework
    # being removed.
    args << "-no-phonon" if MacOS.version >= :sierra || MacOS::Xcode.version >= "8.0"

    args << "-openssl-linked"
    args << "-I" << Formula["openssl"].opt_include
    args << "-L" << Formula["openssl"].opt_lib

    args << "-plugin-sql-mysql" if build.with? "mysql"
    args << "-plugin-sql-psql" if build.with? "postgresql"

    if build.with? "dbus"
      dbus_opt = Formula["dbus"].opt_prefix
      args << "-I#{dbus_opt}/lib/dbus-1.0/include"
      args << "-I#{dbus_opt}/include/dbus-1.0"
      args << "-L#{dbus_opt}/lib"
      args << "-ldbus-1"
      args << "-dbus-linked"
    end

    if build.with? "qt3support"
      args << "-qt3support"
    else
      args << "-no-qt3support"
    end

    args << "-nomake" << "docs" if build.without? "docs"

    if MacOS.prefer_64_bit?
      args << "-arch" << "x86_64"
    else
      args << "-arch" << "x86"
    end

    args << "-no-webkit" if build.without? "webkit"

    system "./configure", *args
    system "make"
    ENV.deparallelize
    system "make", "install"

    # what are these anyway?
    (bin+"pixeltool.app").rmtree
    (bin+"qhelpconverter.app").rmtree
    # remove porting file for non-humans
    (prefix+"q3porting.xml").unlink if build.without? "qt3support"

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink Dir["#{lib}/*.framework"]

    # The pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders.
    Pathname.glob("#{lib}/*.framework/Headers") do |path|
      include.install_symlink path => path.parent.basename(".framework")
    end

    # Make `HOMEBREW_PREFIX/lib/qt-4/plugins` an additional plug-in search path
    # for Qt Designer to support formulae that provide Qt Designer plug-ins.
    system "/usr/libexec/PlistBuddy",
            "-c", "Add :LSEnvironment:QT_PLUGIN_PATH string \"#{HOMEBREW_PREFIX}/lib/qt-4/plugins\"",
           "#{bin}/Designer.app/Contents/Info.plist"

    Pathname.glob("#{bin}/*.app") { |app| mv app, prefix }
  end

  def post_install
    (HOMEBREW_PREFIX/"lib/qt-4/plugins/designer").mkpath
  end

  def caveats; <<~EOS
    We agreed to the Qt opensource license for you.
    If this is unacceptable you should uninstall.

    Qt Designer no longer picks up changes to the QT_PLUGIN_PATH environment
    variable as it was tweaked to search for plug-ins provided by formulae in
      #{HOMEBREW_PREFIX}/lib/qt-4/plugins

    Phonon is not supported on macOS Sierra or with Xcode 8.
    EOS
  end

  test do
    Encoding.default_external = "UTF-8" unless RUBY_VERSION.start_with? "1."
    resource("test-project").stage testpath
    system bin/"qmake"
    system "make"
    assert_match(/GitHub/, pipe_output(testpath/"qtnetwork-test 2>&1", nil, 0))
  end
end
