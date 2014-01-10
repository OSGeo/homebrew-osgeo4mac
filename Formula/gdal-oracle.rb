require "formula"
require File.expand_path("../../Requirements/gdal_third_party", Pathname.new(__FILE__).realpath)

class GdalOracle < Formula
  homepage "http://www.gdal.org/ogr/drv_oci.html"
  url "http://download.osgeo.org/gdal/1.10.1/gdal-1.10.1.tar.gz"
  sha1 "b4df76e2c0854625d2bedce70cc1eaf4205594ae"

  option "with-basic", "Intall using Oracle's Basic client, instead of Basic Lite"

  depends_on GdalThirdParty
  depends_on "gdal"

  # downloads: "http://www.oracle.com/technetwork/topics/intel-macsoft-096467.html"
  resource "basic" do
    url "file://#{ENV["GDAL_THIRD_PARTY"]}/instantclient-basic-macos.x64-11.2.0.3.0.zip"
    sha1 "451fe2e8b9e92ad45760880116792ae31a4f0174"
  end

  resource "basiclite" do
    url "file://#{ENV["GDAL_THIRD_PARTY"]}/instantclient-basiclite-macos.x64-11.2.0.3.0.zip"
    sha1 "22794c7ee551ffc3a8b21fb7c151a3e1c14833a8"
  end

  resource "sdk" do
    url "file://#{ENV["GDAL_THIRD_PARTY"]}/instantclient-sdk-macos.x64-11.2.0.3.0.zip"
    sha1 "95875708dec52155aa6b6f66550b805fd0875c26"
  end

  def install

    # stage third-party libs in prefix
    oracle = prefix/"oracle"
    oracle_opt = opt_prefix/"oracle"
    oracle_bin = oracle/"bin"
    oracle_lib = oracle/"lib"
    oracle_opt_lib = oracle_opt/"lib"
    (oracle_bin).mkpath
    (oracle_lib).mkpath

    basic = (build.with? "basic") ? "basic" : "basiclite"
    oracle_exes = %W[adrci genezi uidrvci]

    resource(basic).stage do
      oracle.install Dir["*README"]
      oracle_lib.install "libclntsh.dylib.11.1" => "libclntsh.dylib"
      #oracle_lib.install "libocci.dylib.11.1" => "libocci.dylib"
      oracle_lib.install "libnnz11.dylib"
      oracle_bin.install oracle_exes
    end

    resource("sdk").stage do
      cd "sdk" do
        oracle.install "include", "demo", "SDK_README"
      end
    end

    # link to binary executables
    bin.mkpath
    cd bin do
      oracle_exes.each {|f| ln_s oracle_bin/"#{f}", f}
    end

    # update third-party libs
    cd oracle_lib do
      system "install_name_tool", "-id",
             "#{oracle_opt_lib}/libclntsh.dylib",
             "libclntsh.dylib"
      system "install_name_tool", "-id",
             "#{oracle_opt_lib}/libnnz11.dylib",
             "libnnz11.dylib"
    end

    def dylib_change(dylib, old, new)
      system "install_name_tool", "-change", old, new, dylib
    end

    (oracle_exes + %W[libclntsh.dylib]).each do |b|
      prfx = (b.end_with? "dylib") ? oracle_lib : oracle_bin
      dylib_change(prfx/"#{b}",
                   "/ade/b/2649109290/oracle/rdbms/lib/libclntsh.dylib.11.1",
                   "#{oracle_opt_lib}/libclntsh.dylib")
      dylib_change(prfx/"#{b}",
                   "/ade/b/2649109290/oracle/ldap/lib/libnnz11.dylib",
                   "#{oracle_opt_lib}/libnnz11.dylib")
    end

    (lib/"gdalplugins").mkpath
    args = []

    # source files
    args.concat %W[ogr/ogrsf_frmts/oci/oci_utils.cpp]
    Dir["ogr/ogrsf_frmts/oci/ogr*.c*"].each do |src|
      args.concat %W[#{src}]
    end

    # plugin dylib
    # TODO: can the compatibility_version be 1.10.0?
    args.concat %W[
      -dynamiclib
      -install_name #{HOMEBREW_PREFIX}/lib/gdalplugins/ogr_OCI.dylib
      -current_version #{version}
      -compatibility_version #{version}
      -o #{lib}/gdalplugins/ogr_OCI.dylib
      -undefined dynamic_lookup
    ]

    # cxx flags
    args.concat %W[-Iport -Igcore -Iogr -Iogr/ogrsf_frmts
                   -Iogr/ogrsf_frmts/oci -I#{oracle}/include]

    # ld flags
    args.concat %W[-L#{oracle_lib} -lclntsh]

    # build and install shared plugin
    system ENV.cxx, *args

  end

  def caveats; <<-EOS.undent
      This formula provides a plugin that allows GDAL or OGR to access geospatial
      data stored in its format. In order to use the shared plugin, you will need
      to set the following enviroment variable:

        export GDAL_DRIVER_PATH=#{HOMEBREW_PREFIX}/lib/gdalplugins

      The MrSID libraries are `keg-only`. To build software that uses them, add
      to the following environment variables:

        CPPFLAGS: -I#{opt_prefix}/oracle/include
        LDFLAGS:  -L#{opt_prefix}/oracle/lib

  EOS
  end
end
