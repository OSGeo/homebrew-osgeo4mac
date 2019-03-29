class OsgeoVtk < Formula
  # include Language::Python::Virtualenv
  desc "Toolkit for 3D computer graphics, image processing, and visualization"
  homepage "https://www.vtk.org/"
  url "https://www.vtk.org/files/release/8.2/VTK-8.2.0.tar.gz"
  sha256 "34c3dc775261be5e45a8049155f7228b6bd668106c72a3c435d95730d17d57bb"

  revision 5

  head "https://github.com/Kitware/VTK.git"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    rebuild 1
    sha256 "12c53fe71192dd5b1380c527fbfa0868fe551db147f92c99896ae8ffa6018f47" => :mojave
    sha256 "12c53fe71192dd5b1380c527fbfa0868fe551db147f92c99896ae8ffa6018f47" => :high_sierra
    sha256 "621d6c533add4a60579de6527de171e47be7ddc070dbf493c5a07c6790e72e1c" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "fontconfig"
  depends_on "hdf5"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "osgeo-netcdf"
  depends_on "python"
  depends_on "qt"

  depends_on "gcc"
  depends_on "double-conversion"
  depends_on "doxygen"
  depends_on "ffmpeg"
  depends_on "gnuplot"

  depends_on "tcl-tk"
  depends_on "unixodbc"
  depends_on "wget"
  depends_on "eigen"
  depends_on "expat"
  depends_on "freetype"
  depends_on "glew"
  depends_on "jsoncpp"
  depends_on "libxml2"
  depends_on "lz4"
  depends_on "xz"
  depends_on "libogg"
  depends_on "pegtl"
  depends_on "pugixml"
  depends_on "ffmpeg2theora"
  depends_on "zlib"
  depends_on "osgeo-proj"
  depends_on "sqlite"
  depends_on "graphviz"

  depends_on "osgeo-gdal"
  depends_on "osgeo-pyqt"
  depends_on "osgeo-qt-webkit"
  depends_on "osgeo-matplotlib"

  # JAVA_VERSION = "1.8" # "1.10+"
  depends_on :java => ["1.8", :build] # JAVA_VERSION

  depends_on "eigen"
  depends_on "gl2ps"
  depends_on "libharu"
  # depends_on "mysql"
  depends_on "mysql-client"
  depends_on "openslide"
  depends_on "osgeo-postgresql"
  depends_on "tbb"
  depends_on "inetutils"

  depends_on "open-mpi"
  # depends_on "osgeo-mpi4py"

  def install
    # Warning: python modules have explicit framework links
    # These python extension modules were linked directly to a Python
    # framework binary. They should be linked with -undefined dynamic_lookup
    # instead of -lpython or -framework Python
    # ENV["PYTHON_LIBS"] = "-undefined dynamic_lookup"
    # PYTHON_LDFLAGS=-undefined dynamic_lookup
    # PYTHON_EXTRA_LIBS=-undefined dynamic_lookup
    # PYTHON_EXTRA_LDFLAGS=-undefined dynamic_lookup

    python_executable = `which python3`.strip
    python_prefix = `#{python_executable} -c 'import sys;print(sys.prefix)'`.chomp
    python_include = `#{python_executable} -c 'from distutils import sysconfig;print(sysconfig.get_python_inc(True))'`.chomp
    python_version = "python" + `#{python_executable} -c 'import sys;print(sys.version[:3])'`.chomp
    py_site_packages = "#{lib}/#{python_version}/site-packages"

    # # install python environment
    # venv = virtualenv_create(libexec/'vendor', "#{Formula["python"].opt_bin}/python3")
    #
    # res_required = ['setuptools', 'mpi4py']
    #
    # res_required.each do |r|
    #     venv.pip_install r
    # end

    cmd = Language::Java.java_home_cmd("1.8") # JAVA_VERSION
    ENV["JAVA_HOME"] = Utils.popen_read(cmd).chomp

    args = std_cmake_args + %W[
      -DBUILD_SHARED_LIBS=ON
      -DBUILD_TESTING=OFF
      -DCMAKE_INSTALL_NAME_DIR:STRING=#{lib}
      -DCMAKE_INSTALL_RPATH:STRING=#{lib}
      -DModule_vtkInfovisBoost=ON
      -DModule_vtkInfovisBoostGraphAlgorithms=ON
      -DModule_vtkRenderingFreeTypeFontConfig=ON
      -DVTK_REQUIRED_OBJCXX_FLAGS=''
      -DVTK_USE_COCOA=ON
      -DVTK_USE_SYSTEM_EXPAT=ON
      -DVTK_USE_SYSTEM_HDF5=ON
      -DVTK_USE_SYSTEM_JPEG=ON
      -DVTK_USE_SYSTEM_LIBXML2=ON
      -DVTK_USE_SYSTEM_NETCDF=ON
      -DVTK_USE_SYSTEM_PNG=ON
      -DVTK_USE_SYSTEM_TIFF=ON
      -DVTK_USE_SYSTEM_ZLIB=ON
      -DVTK_WRAP_PYTHON=ON
      -DPYTHON_EXECUTABLE=#{python_executable}
      -DPYTHON_INCLUDE_DIR=#{python_include}
      -DVTK_PYTHON_SITE_PACKAGES_SUFFIX=#{py_site_packages}
      -DVTK_QT_VERSION:STRING=5
      -DVTK_Group_Qt=ON
      -DVTK_WRAP_PYTHON_SIP=ON
      -DSIP_PYQT_DIR=#{HOMEBREW_PREFIX}/share/sip/PyQt5

      -DVTK_USE_FFMPEG_ENCODER=ON
      -DVTK_USE_LARGE_DATA=ON
      -DVTK_WRAP_JAVA=ON
      -DVTK_WRAP_TCL=ON
      -DCMAKE_CXX_FLAGS="-D__STDC_CONSTANT_MACROS"
      -DVTK_PYTHON_VERSION:STRING=3
    ]

    # args << "-DCMAKE_SKIP_RPATH=ON"
    # args << "-DBUILD_DOCUMENTATION=OFF"
    # args << "-DDOXYGEN_KEEP_TEMP=ON"
    # args << "-DDOCUMENTATION_HTML_HELP=OFF"
    # args << "-DDOCUMENTATION_HTML_TARZ=OFF"
    # args << "-DBUILD_EXAMPLES=ON"
    # args << "-DXDMF_STATIC_AND_SHARED=OFF"

    # args << "-DVTK_USE_TK=ON"
    # args << "-DVTK_USE_EXTERNAL=ON"

    # For MPI4PY

    # args << "-DVTK_USE_SYSTEM_MPI4PY=OFF"

    # disable for error build ThirdParty/mpi4py
    # args << "-DVTK_USE_MPI=OFF"

    # args << "-Dmpi4py_INCLUDE_DIR=#{libexec}/vendor/lib/python#{python_version}/site-packages/mpi4py/include"

    # args << "-DVTK_GROUP_ENABLE_Rendering:STRING=WANT"
    # args << "-DVTK_GROUP_ENABLE_StandAlone:STRING=WANT"
    # args << "-DVTK_GROUP_ENABLE_Imaging:STRING=WANT"
    # args << "-DVTK_GROUP_ENABLE_MPI:STRING=DONT_WANT"
    # args << "-DVTK_GROUP_ENABLE_Views:STRING=WANT"
    # args << "-DVTK_GROUP_ENABLE_Qt:STRING=WANT"
    # args << "-DVTK_GROUP_ENABLE_Web:STRING=WANT"

    # args << "-DVTK_Group_Rendering:BOOL=ON"
    # args << "-DVTK_Group_StandAlone:BOOL=ON"
    # args << "-DVTK_Group_Imaging:BOOL=ON"
    # args << "-DVTK_Group_MPI:BOOL=OFF"
    # args << "-DVTK_Group_Views:BOOL=ON"
    # args << "-DVTK_Group_Qt:BOOL=ON"
    # args << "-DVTK_Group_Web:BOOL=ON"

    # args << "-DVTK_MODULE_ENABLE_VTK_ParallelMPI4Py:BOOL=OFF"
    # args << "-DModule_vtkParallelMPI4Py:BOOL=OFF"

    args << "-DVTK_BUILD_ALL_MODULES=ON"

    # For some reason, when ThirdParty/mpi4py is built it fails
    # The options (see above) to disable it do not seem to work
    # A non-ideal solution is applied, but that works to deactivate it
    mv "#{buildpath}/Parallel/MPI4Py/CMakeLists.txt", "#{buildpath}/Parallel/MPI4Py/CMakeLists.txt.bk"
    mv "#{buildpath}/Parallel/MPI4Py/module.cmake", "#{buildpath}/Parallel/MPI4Py/module.cmake.bk"
    mv "#{buildpath}/ThirdParty/mpi4py/CMakeLists.txt", "#{buildpath}/ThirdParty/mpi4py/CMakeLists.txt.bk"
    mv "#{buildpath}/ThirdParty/mpi4py/module.cmake", "#{buildpath}/ThirdParty/mpi4py/module.cmake.bk"

    # CMake picks up the system's python dylib, even if we have a brewed one.
    if File.exist? "#{python_prefix}/Python"
      args << "-DPYTHON_LIBRARY='#{python_prefix}/Python'"
    elsif File.exist? "#{python_prefix}/lib/lib#{python_version}.a"
      args << "-DPYTHON_LIBRARY='#{python_prefix}/lib/lib#{python_version}.a'"
    elsif File.exist? "#{python_prefix}/lib/lib#{python_version}.dylib"
      args << "-DPYTHON_LIBRARY='#{python_prefix}/lib/lib#{python_version}.dylib'"
    else
      odie "No libpythonX.Y.{dylib|a} file found!"
    end

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end

    # Avoid hard-coding Python's Cellar paths
    inreplace Dir["#{lib}/cmake/**/vtkPython.cmake"].first,
      Formula["python"].prefix.realpath,
      Formula["python"].opt_prefix

    # Avoid hard-coding HDF5's Cellar path
    inreplace Dir["#{lib}/cmake/**/vtkhdf5.cmake"].first,
      Formula["hdf5"].prefix.realpath,
      Formula["hdf5"].opt_prefix

    # fix lib/python
    # maybe the reason is that it was changed VTK_INSTALL_PYTHON_MODULE_DIR
    # by VTK_PYTHON_SITE_PACKAGES_SUFFIX
    mv "#{lib}/#{lib}/#{python_version}", "#{lib}/#{python_version}"
    rm_r "#{lib}/usr"

    # fix: Could not fix @rpath/libjawt.dylib
    MachO::Tools.change_install_name("#{lib}/libvtkChartsCoreJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkDomainsChemistryJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkDomainsChemistryOpenGL2Java.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkDomainsParallelChemistryJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkFiltersHybridJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkFiltersParallelDIY2Java.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkFiltersParallelGeometryJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkFiltersParallelImagingJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkFiltersParallelJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkFiltersParallelMPIJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkGeovisCoreJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkIOExportJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkIOExportOpenGL2Java.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkIOExportPDFJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkIOImportJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkIOMINCJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkIOMPIParallelJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkIOParallelJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkInteractionImageJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkInteractionStyleJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkInteractionWidgetsJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingAnnotationJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingContext2DJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingContextOpenGL2Java.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingCoreJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingFreeTypeJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingGL2PSOpenGL2Java.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingImageJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingLICOpenGL2Java.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingLODJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingLabelJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingMatplotlibJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingOpenGL2Java.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingParallelJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingParallelLICJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingQtJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingSceneGraphJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingVolumeAMRJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingVolumeJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkRenderingVolumeOpenGL2Java.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkTestingRenderingJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkViewsContext2DJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkViewsCoreJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkViewsGeovisJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")
    MachO::Tools.change_install_name("#{lib}/libvtkViewsInfovisJava.dylib", "@rpath/libjawt.dylib", "#{ENV["JAVA_HOME"]}/jre/lib/libjawt.dylib")

    # Warning: JARs were installed to "/usr/local/opt/osgeo-vtk/lib"
    # Installing JARs to "lib" can cause conflicts between packages.
    # For Java software, it is typically better for the formula to
    # install to "libexec" and then symlink or wrap binaries into "bin".
    # See "activemq", "jruby", etc. for examples.
    # The offending files are:
    #   /usr/local/opt/osgeo-vtk/lib/vtk.jar
    # libexec.install Dir["*"]
    # bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    vtk_include = Dir[opt_include/"vtk-*"].first
    major, minor = vtk_include.match(/.*-(.*)$/)[1].split(".")

    (testpath/"version.cpp").write <<~EOS
      #include <vtkVersion.h>
      #include <assert.h>
      int main(int, char *[]) {
        assert (vtkVersion::GetVTKMajorVersion()==#{major});
        assert (vtkVersion::GetVTKMinorVersion()==#{minor});
        return EXIT_SUCCESS;
      }
    EOS

    system ENV.cxx, "-std=c++11", "version.cpp", "-I#{vtk_include}"
    system "./a.out"
    system "#{bin}/vtkpython", "-c", "exit()"
  end
end
