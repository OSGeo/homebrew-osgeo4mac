class Pdfium < Formula
  ver = "3625".freeze # relates to chromium version

  desc "Google-contributed PDF library (without V8 JavaScript engine)"
  homepage "https://pdfium.googlesource.com/pdfium/"
  url "https://pdfium.googlesource.com/pdfium.git",
      :branch => "chromium/#{ver}"
  version ver

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any_skip_relocation
    sha256 "8d36c01cd5d05370bbcdfc8e33e74b1784b8373d4d0184a954db207079e2a605" => :mojave
    sha256 "8d36c01cd5d05370bbcdfc8e33e74b1784b8373d4d0184a954db207079e2a605" => :high_sierra
    sha256 "8d36c01cd5d05370bbcdfc8e33e74b1784b8373d4d0184a954db207079e2a605" => :sierra
  end

  depends_on "python@2" => :build # gyp doesn't run under 2.6 or lower

  resource "depot_tools" do
    url "https://chromium.googlesource.com/chromium/tools/depot_tools.git"
  end

  resource "chromium_icu" do
    url "https://chromium.googlesource.com/chromium/deps/icu.git",
      :revision => "e4194dc7bbb3305d84cbb1b294274ca70d230721"
  end

  def pdfium_build_dir
    "out/Release_x64"
  end

  def copy_file_and_dir_path(dir_search, dst_pathname)
    Dir[dir_search].each do |f|
      dst = dst_pathname/File.dirname(f)
      dst.mkpath
      dst.install(f)
    end
  end

  def install
    # need to move git checkout into gclient solutions directory
    base_install = Dir[".*", "*"] - [".", "..", ".brew_home"]
    (buildpath/"pdfium/").mkpath
    base_install.each { |f| mv f, buildpath/"pdfium/" }

    # install chromium's build tools, includes ninja and gyp
    (buildpath/"depot_tools").install resource("depot_tools")
    ENV.prepend_path "PATH", buildpath/"depot_tools"

    # Add Chromium ICU
    (buildpath/"pdfium/third_party/icu").install resource("chromium_icu")

    # use pdfium's gyp scripts to create ninja build files.
    ENV["GYP_GENERATORS"] = "ninja"

    system "gclient", "config", "--unmanaged", "--name=pdfium",
           "https://pdfium.googlesource.com/pdfium.git" # @#{pdfium_rev}

    system "gclient", "sync", "--no-history" # "--shallow"

    cd "pdfium" do
      cwdir = Pathname.new(Dir.pwd)
      # system "./build/install-build-deps.sh" # Linux-only
      (cwdir/pdfium_build_dir).mkpath
      # write out config args
      (cwdir/"#{pdfium_build_dir}/args.gn").write <<~EOS
        # Build arguments go here.
        # See "gn args <out_dir> --list" for available build arguments.
        use_goma=false
        is_debug=false
        pdf_use_skia=false
        pdf_use_skia_paths=false
        pdf_enable_xfa=false
        pdf_enable_v8=false
        pdf_is_standalone=true
        pdf_is_complete_lib=true
        is_component_build=false
        clang_use_chrome_plugins=false
        is_clang=true
        mac_deployment_target="#{MacOS.version}"
      EOS
      system "gn", "gen", pdfium_build_dir

      # compile release build of pdfium & its test binaries
      system "ninja", "-C", pdfium_build_dir, "pdfium_all"

      # copy header files into a pdfium directory
      copy_file_and_dir_path("core/**/*.h", include/"pdfium")
      copy_file_and_dir_path("fpdfsdk/**/*.h", include/"pdfium")
      (include/"pdfium").install Dir["public/**/*.h"]

      # and 3rd party dependency headers
      (include/"pdfium/third_party/base/numerics").install Dir["third_party/base/numerics/*.h"]
      (include/"pdfium/third_party/base").install Dir["third_party/base/*.h"]

      # test data
      (libexec/"testing/resources").install Dir["testing/resources/*"]

      cd pdfium_build_dir do
        (lib/"pdfium").install Dir["obj/lib*.a"]
        bin.install "pdfium_test", "pdfium_diff"
        (libexec/pdfium_build_dir).install Dir["pdfium_*tests"]
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
    system libexec/"#{pdfium_build_dir}/pdfium_unittests"
    system libexec/"#{pdfium_build_dir}/pdfium_embeddertests"
  end
end
