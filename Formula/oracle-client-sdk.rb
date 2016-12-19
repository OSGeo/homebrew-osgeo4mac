require File.expand_path("../../Strategies/cache-download", Pathname.new(__FILE__).realpath)

class OracleClientSdk < Formula
  desc "Oracle database C/C++ client libs, command-line tools and SDK"
  homepage "http://www.oracle.com/technetwork/topics/intel-macsoft-096467.html"
  option "with-basic", "Intall Oracle's Basic client, instead of Basic Lite"

  if build.with? "basic"
    url "file://#{HOMEBREW_CACHE}/instantclient-basic-macos.x64-12.1.0.2.0.zip",
        :using => CacheDownloadStrategy
    sha256 "ecbf84ff011fcd8981c2cd9355f958ee42b2e452ebaad2d42df7b226903679cf"
  else
    url "file://#{HOMEBREW_CACHE}/instantclient-basiclite-macos.x64-12.1.0.2.0.zip",
        :using => CacheDownloadStrategy
    sha256 "ac7e97661a2bfac69b3262150641914f456c7806ba2a7850669fb83abac120e8"
  end

  resource "sdk" do
    url "file://#{HOMEBREW_CACHE}/instantclient-sdk-macos.x64-12.1.0.2.0.zip",
        :using => CacheDownloadStrategy
    sha256 "63582d9a2f4afabd7f5e678c39bf9184d51625c61e67372acdbc7b42ed8530ac"
  end

  def install
    oracle_exes = %w[adrci genezi uidrvci]
    ver_split = version.to_s.split(".")
    maj_ver = ver_split[0]
    min_ver = ver_split[1]

    # client data shared library
    cdslib = build.with?("basic") ? "libociei" : "libociicus"

    # fix permissions
    chmod 0644, Dir["*"]
    chmod 0755, oracle_exes

    # fixup lib naming to macOS style
    %w[libclntsh libclntshcore libocci].each do |f|
      mv "#{f}.dylib.#{maj_ver}.#{min_ver}", "#{f}.#{maj_ver}.#{min_ver}.dylib"
      ln_sf "#{f}.#{maj_ver}.#{min_ver}.dylib", "#{f}.dylib"
    end

    # update install names to opt_prefix (probably done by Homebrew as well)
    %W[libclntsh libnnz#{maj_ver} libocci #{cdslib} libons].each do |f|
      quiet_system "install_name_tool", "-id", "#{opt_lib/f}.dylib", "#{f}.dylib"
    end

    # fix @rpath cross-linkage
    rpath_fixes = %W[libclntsh.dylib libnnz#{maj_ver}.dylib #{cdslib}.dylib] + oracle_exes
    rpath_fixes.each do |m|
      dylibs = (buildpath/m).dynamically_linked_libraries
      dylibs.each do |d|
        next unless d.to_s =~ /^@rpath/
        system "install_name_tool", "-change",
               d, d.sub(%r{^@rpath/([^\.]+).*$}, "#{opt_lib}/\\1.dylib"), m.to_s
      end
    end

    # install fixed-up libs and exes
    %W[libclntsh libnnz#{maj_ver} libocci #{cdslib} libons].each { |f| lib.install Dir["#{f}*"] }
    bin.install oracle_exes

    # install headers in a logical subdirectory (since some are too generally named)
    resource("sdk").stage do
      cd "sdk" do
        Dir["**/*", "."].each do |f|
          chmod (File.directory?(f.to_s) ? 0755 : 0644), f
        end
        (include/"oci").install Dir["include/*"]
        rmdir "include"
        ln_sf "../include", "./"
      end
      prefix.install "sdk"
    end
  end

  def caveats; <<-EOS.undent
      To build software with the Instant Client SDK, add to the following
      environment variable to find headers:

        [CFLAGS|CPPFLAGS]: -I#{opt_include}/oci

    EOS
  end

  test do
    # From GDAL 2.1.2's configure test
    (testpath/"test.cpp").write <<-EOS.undent
    #include <oci.h>
    int main () {
      OCIEnv* envh = 0;
      OCIEnvCreate(&envh, OCI_DEFAULT, 0, 0, 0, 0, 0, 0);
      if (envh) OCIHandleFree(envh, OCI_HTYPE_ENV);
      return 0;
    }
    EOS
    system ENV.cxx, "test.cpp",
           "-I#{opt_include}/oci", "-L#{opt_lib}", "-lclntsh", "-o", "test"
    system "./test"
  end
end
