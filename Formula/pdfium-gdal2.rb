class PdfiumGdal2 < Formula
  desc "Google-contributed PDF library (without V8 JavaScript engine)"
  homepage "https://pdfium.googlesource.com/pdfium/"
  url "https://github.com/rouault/pdfium.git",
      :branch => "master",
      :revision => "b5009c4df5aa4ff923ede1c5deba1aa4be43199b"
  version "0.0.1"

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    cellar :any_skip_relocation
    sha256 "fe5fdc234a1c6486bd3d9d4a559574cdc4125462d4a1e04a2a42286e775b2c3c" => :sierra
  end

  keg_only "newer version of pdfium may be installed"

  depends_on :python => :build # gyp doesn't run under 2.6 or lower
  depends_on :xcode => :build

  resource "depot_tools" do
    url "https://chromium.googlesource.com/chromium/tools/depot_tools.git"
  end

  resource "gyp" do
    url "https://chromium.googlesource.com/external/gyp.git"
  end

  def install
    # ENV.libstdcxx

    # need to move git checkout into gclient solutions directory
    base_install = Dir[".*", "*"] - [".", "..", ".brew_home"]
    (buildpath/"pdfium/").mkpath
    base_install.each { |f| mv f, buildpath/"pdfium/" }

    # install chromium's build tools, includes ninja and gyp
    (buildpath/"pdfium_deps/depot_tools").install resource("depot_tools")
    ENV.prepend_path "PATH", buildpath/"pdfium_deps/depot_tools"

    ENV["GYP_DEFINES"] = "clang=0 mac_deployment_target=#{MacOS.version}"
    (buildpath/"pdfium_deps/gyp").install resource("gyp")
    ENV.prepend_path "PATH", buildpath/"pdfium_deps/gyp"
    ENV.prepend_create_path "PYTHONPATH", buildpath/"pdfium_deps/gyp/pylib"

    # raise

    cd "pdfium" do
      build_dir = "#{buildpath}/pdfium/build"

      system "./build/gyp_pdfium"

      xcodebuild "SDKROOT=#{MacOS.sdk_path}",
                 "MACOSX_DEPLOYMENT_TARGET=10.8",
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
                   "MACOSX_DEPLOYMENT_TARGET=10.8",
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
                   "MACOSX_DEPLOYMENT_TARGET=10.8",
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

      cd "build/Release" do
        (lib/"pdfium").install Dir["lib*.a"]
        (libexec/"bin").install "pdfium_test", "pdfium_diff"
      end
    end
  end

  def caveats; <<-EOS.undent
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
