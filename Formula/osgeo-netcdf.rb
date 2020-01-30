class Unlinked < Requirement
  fatal true

  satisfy(:build_env => false) { !core_netcdf_linked }

  def core_netcdf_linked
    Formula["netcdf"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "\033[31mYou have other linked versions!\e[0m\n\n"

    s += "Unlink with \e[32mbrew unlink netcdf\e[0m or remove with \e[32mbrew uninstall --ignore-dependencies netcdf\e[0m\n\n" if core_netcdf_linked
    s
  end
end

class OsgeoNetcdf < Formula
  desc "Libraries and data formats for array-oriented scientific data"
  homepage "https://www.unidata.ucar.edu/software/netcdf"
  url "https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-c-4.7.3.tar.gz"
  sha256 "8e8c9f4ee15531debcf83788594744bd6553b8489c06a43485a15c93b4e0448b"

  # revision 1

  bottle do
    root_url "https://bottle.download.osgeo.org"
    rebuild 1
    sha256 "9856d7555ee20cc9b109e3513585c0efccfbf3fac844bf9d1f649ee43068584d" => :mojave
    sha256 "9856d7555ee20cc9b109e3513585c0efccfbf3fac844bf9d1f649ee43068584d" => :high_sierra
    sha256 "1d8c6147e523273341defa90e7bd67dc1dbb5cf616e352345d922131744fc455" => :sierra
  end

  # keg_only "netcdf is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

  depends_on "cmake" => :build
  depends_on "gcc" # for gfortran
  depends_on "hdf5"

  resource "cxx" do
    url "https://github.com/Unidata/netcdf-cxx4/archive/v4.3.1.tar.gz"
    sha256 "e3fe3d2ec06c1c2772555bf1208d220aab5fee186d04bd265219b0bc7a978edc"
  end

  resource "cxx-compat" do
    url "https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-cxx-4.2.tar.gz"
    sha256 "95ed6ab49a0ee001255eac4e44aacb5ca4ea96ba850c08337a3e4c9a0872ccd1"
  end

  resource "fortran" do
    url "https://github.com/Unidata/netcdf-fortran/archive/v4.5.2.tar.gz"
    sha256 "0b05c629c70d6d224a3be28699c066bfdfeae477aea211fbf034d973a8309b49"
  end

  def install
    ENV.deparallelize

    ENV.prepend "CPPFLAGS", "-I#{include}"
    ENV.prepend "LDFLAGS", "-L#{lib}"
    # ENV.append "CFLAGS", "#{CFLAGS}

    args_c = %W[
        -DCMAKE_INSTALL_PREFIX=#{prefix}
        -DCMAKE_INSTALL_LIBDIR=#{lib}
    		-DCMAKE_BUILD_TYPE=Release
    		-DENABLE_CDF5=ON
    		-DENABLE_DAP_LONG_TESTS=ON
    		-DENABLE_EXAMPLE_TESTS=ON
    		-DENABLE_EXTRA_TESTS=ON
    		-DENABLE_FAILING_TESTS=ON
    		-DENABLE_FILTER_TESTING=ON
    		-DENABLE_LARGE_FILE_TESTS=ON
        -DENABLE_TESTS=OFF
        -DENABLE_NETCDF_4=ON
        -DENABLE_DOXYGEN=OFF
        -DENABLE_DAP_AUTH_TESTS=OFF
        -DBUILD_TESTING=OFF
      ]

    mkdir "build" do
      args_c << "-DNC_EXTRA_DEPS=-lmpi" if Tab.for_name("hdf5").with? "mpi"
      system "cmake", "..", "-DBUILD_SHARED_LIBS=ON", *args_c
      system "make", "install"
      system "make", "clean"
      system "cmake", "..", "-DBUILD_SHARED_LIBS=OFF", *args_c
      system "make"
      lib.install "liblib/libnetcdf.a"
    end

    common_args = std_cmake_args
    # Add newly created installation to paths so that binding libraries can
    # find the core libs.
    args = common_args.dup << "-DNETCDF_C_LIBRARY=#{lib}/libnetcdf.dylib"

    cxx_args = args.dup
    cxx_args << "-DNCXX_ENABLE_TESTS=OFF"
    resource("cxx").stage do
      mkdir "build-cxx" do
        # system "./configure", "--enable-shared", "--enable-extra-tests", "--enable-large-file-tests"
        # --prefix=/usr
        system "cmake", "..", "-DBUILD_SHARED_LIBS=ON", *cxx_args
        system "make", "install"
        system "make", "clean"
        system "cmake", "..", "-DBUILD_SHARED_LIBS=OFF", *cxx_args
        system "make"
        lib.install "cxx4/libnetcdf-cxx4.a"
      end
    end

    fortran_args = args.dup
    fortran_args << "-DENABLE_TESTS=OFF"
    resource("fortran").stage do
      mkdir "build-fortran" do
        system "cmake", "..", "-DBUILD_SHARED_LIBS=ON", *fortran_args
        system "make", "install"
        system "make", "clean"
        system "cmake", "..", "-DBUILD_SHARED_LIBS=OFF", *fortran_args
        system "make"
        lib.install "fortran/libnetcdff.a"
      end
    end

    resource("cxx-compat").stage do
      system "./configure", "--disable-dependency-tracking",
                            "--enable-shared",
                            "--enable-static",
                            "--prefix=#{prefix}"
      system "make"
      system "make", "install"
    end

    # SIP causes system Python not to play nicely with @rpath
    libnetcdf = (lib/"libnetcdf.dylib").readlink
    %w[libnetcdf-cxx4.dylib libnetcdf_c++.dylib].each do |f|
      macho = MachO.open("#{lib}/#{f}")
      macho.change_dylib("@rpath/#{libnetcdf}",
                         "#{lib}/#{libnetcdf}")
      macho.write!
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include "netcdf_meta.h"
      int main()
      {
        printf(NC_VERSION);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-I#{include}", "-lnetcdf",
                   "-o", "test"
    assert_equal `./test`, version.to_s

    (testpath/"test.f90").write <<~EOS
      program test
        use netcdf
        integer :: ncid, varid, dimids(2)
        integer :: dat(2,2) = reshape([1, 2, 3, 4], [2, 2])
        call check( nf90_create("test.nc", NF90_CLOBBER, ncid) )
        call check( nf90_def_dim(ncid, "x", 2, dimids(2)) )
        call check( nf90_def_dim(ncid, "y", 2, dimids(1)) )
        call check( nf90_def_var(ncid, "data", NF90_INT, dimids, varid) )
        call check( nf90_enddef(ncid) )
        call check( nf90_put_var(ncid, varid, dat) )
        call check( nf90_close(ncid) )
      contains
        subroutine check(status)
          integer, intent(in) :: status
          if (status /= nf90_noerr) call abort
        end subroutine check
      end program test
    EOS
    system "gfortran", "test.f90", "-L#{lib}", "-I#{include}", "-lnetcdff",
                       "-o", "testf"
    system "./testf"
  end
end
