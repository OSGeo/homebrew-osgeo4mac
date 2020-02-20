class OsgeoPdfium < Formula
  desc "Google-contributed PDF library (without V8 JavaScript engine)"
  homepage "https://pdfium.googlesource.com/pdfium/"
  url "https://github.com/rouault/pdfium.git",
      :branch => "master",
      :revision => "b5009c4df5aa4ff923ede1c5deba1aa4be43199b"
  version "0.0.1"

  revision 1

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any_skip_relocation
    rebuild 1
    sha256 "c99e8ad04cda183ba17c53c5dee0c7bfc26ad36ab0ffb24ecbcea5b93f8e2686" => :catalina
    sha256 "c99e8ad04cda183ba17c53c5dee0c7bfc26ad36ab0ffb24ecbcea5b93f8e2686" => :mojave
    sha256 "c99e8ad04cda183ba17c53c5dee0c7bfc26ad36ab0ffb24ecbcea5b93f8e2686" => :high_sierra
  end

  keg_only "newer version of pdfium may be installed"

  depends_on "python" => :build # gyp doesn't run under 2.6 or lower
  depends_on :xcode => :build

  resource "depot_tools" do
    url "https://chromium.googlesource.com/chromium/tools/depot_tools.git"
  end

  resource "gyp" do
    url "https://chromium.googlesource.com/external/gyp.git"
  end

  def install
    #ENV.libstdcxx

    link_misc = "-arch x86_64 -mmacosx-version-min=10.9 -isysroot #{MacOS::Xcode.prefix}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX#{MacOS.version}.sdk -lstdc++"

    ENV.append "LDFLAGS", "#{link_misc} -stdlib=libc++"
    ENV.append "CPATH", "#{MacOS::Xcode.prefix}/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1"

    # need to move git checkout into gclient solutions directory
    base_install = Dir[".*", "*"] - [".", "..", ".brew_home"]
    (buildpath/"pdfium/").mkpath
    base_install.each { |f| mv f, buildpath/"pdfium/" }

    # install chromium's build tools, includes ninja and gyp
    (buildpath/"pdfium_deps/depot_tools").install resource("depot_tools")
    ENV.prepend_path "PATH", buildpath/"pdfium_deps/depot_tools"

    ENV["GYP_DEFINES"] = "#{ENV.cc} mac_deployment_target=#{MacOS.version}"
    (buildpath/"pdfium_deps/gyp").install resource("gyp")
    ENV.prepend_path "PATH", buildpath/"pdfium_deps/gyp"
    ENV.prepend_create_path "PYTHONPATH", buildpath/"pdfium_deps/gyp/pylib"

    # raise

    cd "pdfium" do
      build_dir = "#{buildpath}/pdfium/build"

      system "./build/gyp_pdfium"

      xcodebuild "SDKROOT=#{MacOS.sdk_path}",
                 "MACOSX_DEPLOYMENT_TARGET=10.9",
                 "SYMROOT=#{build_dir}",
                 "ONLY_ACTIVE_ARCH=YES",
                 "-configuration", "Release",
                 "-target", "pdfium",
                 "-target", "fdrm",
                 "-target", "fpdfdoc",
                 "-target", "fpdfapi",
                 "-target", "fpdftext",
                 "-target", "fxcodec",
                 "-target", "fxcrt",
                 "-target", "fxge",
                 "-target", "fxedit",
                 "-target", "pdfwindow",
                 "-target", "formfiller"

      cd "third_party" do
        xcodebuild "SDKROOT=#{MacOS.sdk_path}",
                   "MACOSX_DEPLOYMENT_TARGET=10.9",
                   "SYMROOT=#{build_dir}",
                   "ONLY_ACTIVE_ARCH=YES",
                   "-configuration", "Release",
                   "-target", "bigint",
                   "-target", "freetype",
                   "-target", "fx_agg",
                   "-target", "fx_lcms2",
                   "-target", "fx_zlib",
                   "-target", "pdfium_base",
                   "-target", "fx_libjpeg",
                   "-target", "fx_libopenjpeg"
      end

      cd "samples" do
        inreplace "pdfium_test.cc", /(delete platform;)/, "//\\1"
        xcodebuild "SDKROOT=#{MacOS.sdk_path}",
                   "MACOSX_DEPLOYMENT_TARGET=10.9",
                   "SYMROOT=#{build_dir}",
                   "ONLY_ACTIVE_ARCH=YES",
                   "-configuration", "Release",
                   "-target", "pdfium_test",
                   "-target", "pdfium_diff"
      end

      # raise

      # copy header files into a pdfium directory
      (include/"pdfium").install Dir["public/**/*.h"]
      (include/"pdfium/core/include").install Dir["core/include/*"]
      (include/"pdfium/fpdfsdk/include").install Dir["fpdfsdk/include/*"]

      # and 3rd party dependency headers
      (include/"pdfium/third_party/base/numerics").install Dir["third_party/base/numerics/*.h"]
      (include/"pdfium/third_party/base").install Dir["third_party/base/*.h"]

      # test data
      (libexec/"testing/resources").install Dir["testing/resources/*"]

      # fix public/*.h not found
      cd "#{include}/pdfium" do
        mkdir "public"
        mv "fpdf_progressive.h", "./public/fpdf_progressive.h"
        mv "fpdfview.h", "./public/fpdfview.h"

        ln_s "./public/fpdf_progressive.h", "./fpdf_progressive.h"
        ln_s "./public/fpdfview.h", "./fpdfview.h"
      end

      cd "build/Release" do
        (lib/"pdfium").install Dir["lib*.a"]
        (libexec/"bin").install "pdfium_test", "pdfium_diff"
      end
    end
  end

  def caveats; <<~EOS
    For building other software, static libs are located in
      #{opt_lib}/pdfium

    and includes in
      #{opt_include}/pdfium
  EOS
  end

  test do
    out = shell_output("#{libexec}/bin/pdfium_test 2>&1", 1)
    assert_match "No input files", out

    out = shell_output("#{libexec}/bin/pdfium_diff 2>&1", 2)
    assert_match "Compares two files on disk", out
  end
end
