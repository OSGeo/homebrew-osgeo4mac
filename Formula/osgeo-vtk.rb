class OsgeoVtk < Formula
  # include Language::Python::Virtualenv
  desc "Toolkit for 3D computer graphics, image processing, and visualization"
  homepage "https://www.vtk.org/"
  url "https://www.vtk.org/files/release/8.2/VTK-8.2.0.tar.gz"
  sha256 "34c3dc775261be5e45a8049155f7228b6bd668106c72a3c435d95730d17d57bb"
  # url "https://gitlab.kitware.com/vtk/vtk/-/archive/81221c6aa9076d4d22d388cfa07a46bc13e0cfc7/vtk-81221c6aa9076d4d22d388cfa07a46bc13e0cfc7.tar.gz"
  # sha256 "badeaada5bd2ef93c010dd17445280d032505aad6eb45a5ec423aa1030fe9801"
  # version "8.2.0"

  revision 16

  head "https://github.com/Kitware/VTK.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    sha256 "3f74f585a3250d6308703072c0c008d6c2405b8bb318845b29cfd65efb36610d" => :catalina
    sha256 "3f74f585a3250d6308703072c0c008d6c2405b8bb318845b29cfd65efb36610d" => :mojave
    sha256 "3f74f585a3250d6308703072c0c008d6c2405b8bb318845b29cfd65efb36610d" => :high_sierra
  end

  # resource "FindPEGTL" do
  #   url "https://src.fedoraproject.org/rpms/vtk/raw/master/f/FindPEGTL.cmake"
  #   sha256 "0183debe3b115c8504edb2bf73b1eb4dc7127a864dce077d12c56a0b0ccf1b8a"
  # end

  # Fix compile issues on Mojave and later
    # Files:
            # Infovis/BoostGraphAlgorithms/vtkBoostGraphAdapter.h
  # Error: ‘my_bool’ was not declared in this scope;
    # https://bugs.gentoo.org/692674
    # Files:
            # IO/MySQL/vtkMySQLDatabase.cxx
            # IO/MySQL/vtkMySQLQuery.cxx
  # Add libogg to IOMovie target link libraries
    # Files:
            # IO/Movie/CMakeLists.txt
  # Allow-compilation-on-GLES-platforms
    # On GLES 2.0 platforms (more specifically, for Qt5 "opengl es2" builds),
    # QOpenGLFunctions_3_2_Core does not exist. Since Qt 5.7,
    # QOpenGlFramebufferObject has a static wrapper method for framebuffer blitting, which in worst case is a noop.
    # Files:
            # GUISupport/Qt/QVTKOpenGLNativeWidget.cxx
  # Make code calling proj4 compatible with proj4 5.0 and later
    # GeoVis incompatible with external libproj4 6.0
    # https://gitlab.kitware.com/vtk/vtk/issues/17554
    # https://github.com/OSGeo/proj.4/wiki/proj.h-adoption-status
    # - projects.h is no longer available in 6.0
    # - use of proj_api.h has to be opted in since 6.0, to be removed in 7.0
    # - pj_get_list_ref has been renamed proj_list_operations in 5.0
    # - PJProps is opaque now, its contents can be accessed with proj_pj_info.
    #   As the contents are no longer global, the const char* from
    #   GetProjectionName has to be copied into the vtkGeoProjection object.
    # Files:
            # Geovis/Core/vtkGeoProjection.cxx
            # Geovis/Core/vtkGeoTransform.cxx
            # ThirdParty/libproj/vtk_libproj.h.in
  # Bundled exodusii add missing libpthread
  # Files:
          # ThirdParty/exodusII/vtkexodusII/CMakeLists.txt
  # Bundled libharu add missing libm
    # Files:
            # ThirdParty/libharu/vtklibharu/src/CMakeLists.txt
  # Alt build - FindNetCDF - Wrapping/PythonCor
    # Files:
            # CMake/FindNetCDF.cmake
            # Wrapping/PythonCore/CMakeLists.txt
  # Fix compilation issue due to Python3.7 API change
    # The PyUnicode_AsUTF8() method returns a "const char *" in Py37
    # Files:
            # Wrapping/PythonCore/vtkPythonArgs.cxx
  # Wrap
    # Files:
            # /Wrapping/Tools/CMakeLists.txt
  # Others compile
    # Files:
            # Wrapping/Java/CMakeLists.txt
  # nohtmldoc
    # Files:
            # Utilities/Doxygen/CMakeLists.txt
  # Compatibility for Python 3.8
    # The PyTypeObject struct was modified in Python 3.8, this change is required to avoid compile errors.
    # Files:
            # PythonInterpreter/vtkPythonStdStreamCaptureHelper.h
            # Wrapping/PythonCore/PyVTKMethodDescriptor.cxx
            # Wrapping/PythonCore/PyVTKNamespace.cxx
            # Wrapping/PythonCore/PyVTKReference.cxx
            # Wrapping/PythonCore/PyVTKTemplate.cxx
            # Wrapping/PythonCore/vtkPythonCompatibility.h
            # Wrapping/Tools/vtkWrapPythonClass.c
            # Wrapping/Tools/vtkWrapPythonEnum.c
            # Wrapping/Tools/vtkWrapPythonType.c
  # GDAL
    # Files:
            # IO/GDAL/vtkGDALVectorReader.cxx
  # pthreads declaration
    # Files:
            # ThirdParty/libxml2/vtklibxml2/threads.c
  patch :DATA

  option "with-pg11", "Build with PostgreSQL 11 client"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "fontconfig"
  depends_on "hdf5"
  depends_on "jpeg"
  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "python"
  depends_on "qt"
  depends_on "osgeo-netcdf"
  
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
  depends_on "sqlite"
  depends_on "graphviz"
  depends_on "osgeo-proj"

  depends_on "osgeo-gdal"
  #depends_on "osgeo-pyqt"
  depends_on "pyqt"
  depends_on "osgeo-qt-webkit"
  depends_on "osgeo-matplotlib"

  # JAVA_VERSION = "1.8" # "1.10+"
  depends_on :java => ["1.8", :build] # JAVA_VERSION

  depends_on "gl2ps"
  depends_on "libharu"
  # depends_on "mysql"
  depends_on "mysql-client"
  depends_on "openslide"
  depends_on "tbb"
  depends_on "inetutils"

  if build.with?("pg11")
    depends_on "osgeo-postgresql@11"
  else
    depends_on "osgeo-postgresql"
  end

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

    # support for PROJ 6
    # ENV.append_to_cflags "-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H"

    # Fix build with Java 12
    # sed -i 's/VTK_JAVA_SOURCE_VERSION "1.6"/VTK_JAVA_SOURCE_VERSION "1.7"/
    #        s/VTK_JAVA_TARGET_VERSION "1.6"/VTK_JAVA_TARGET_VERSION "1.7"/' Wrapping/Java/CMakeLists.txt
    inreplace "Wrapping/Java/CMakeLists.txt",
              'VTK_JAVA_SOURCE_VERSION "1.6"', 'VTK_JAVA_SOURCE_VERSION "1.7"'
    inreplace "Wrapping/Java/CMakeLists.txt",
              'VTK_JAVA_TARGET_VERSION "1.6"', 'VTK_JAVA_TARGET_VERSION "1.7"'

    cmd = Language::Java.java_home_cmd("1.8") # JAVA_VERSION
    ENV["JAVA_HOME"] = Utils.popen_read(cmd).chomp
    # export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

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
      -DVTK_PYTHON_VERSION=3
      -DPYTHON_EXECUTABLE=#{python_executable}
      -DPYTHON_INCLUDE_DIR=#{python_include}
      -DVTK_PYTHON_SITE_PACKAGES_SUFFIX=#{py_site_packages}
      -DVTK_INSTALL_PYTHON_MODULE_DIR=#{lib}/#{python_version}/site-packages
      -DVTK_QT_VERSION=5
      -DVTK_Group_Qt=ON
      -DVTK_WRAP_PYTHON_SIP=ON
      -DSIP_PYQT_DIR=#{HOMEBREW_PREFIX}/share/sip/PyQt5

      -DVTK_USE_FFMPEG_ENCODER=ON
      -DVTK_USE_LARGE_DATA=ON
      -DVTK_WRAP_JAVA=ON
      -DVTK_WRAP_TCL=ON
      -DCMAKE_CXX_FLAGS="-D__STDC_CONSTANT_MACROS"
    ]

    # Common with ParaView
    # VTK_USE_SYSTEM_LIB=""
    args << "-DVTK_USE_SYSTEM_DOUBLECONVERSION=ON"
    args << "-DVTK_USE_SYSTEM_EIGEN=ON"
    args << "-DVTK_USE_SYSTEM_FREETYPE=ON"
    args << "-DVTK_USE_SYSTEM_GLEW=ON"
    args << "-DVTK_USE_SYSTEM_JSONCPP=ON"
    args << "-DVTK_USE_SYSTEM_LZ4=ON"
    args << "-DVTK_USE_SYSTEM_LZMA=ON"
    args << "-DVTK_USE_SYSTEM_OGG=ON"
    # args << "-DVTK_USE_SYSTEM_PEGTL=ON"
    args << "-DVTK_USE_SYSTEM_PUGIXML=ON"
    args << "-DVTK_USE_SYSTEM_THEORA=ON"

    args << "-DVTK_USE_SYSTEM_LIBPROJ=ON"
    args << "-DVTK_USE_SYSTEM_SQLITE=ON"


    args << "-DVTK_USE_OGGTHEORA_ENCODER=0N"

    args << "-DOGGTHEORA_ogg_INCLUDE_DIR=#{Formula["libogg"].opt_include}/ogg/ogg.h" # ogg/ogg.h
    args << "-DOGGTHEORA_ogg_LIBRARY=#{Formula["libogg"].opt_lib}/libogg.dylib" # ogg
    args << "-DOGGTHEORA_theora_INCLUDE_DIR=#{Formula["theora"].opt_include}/theora/theora.h" # theora/theora.h
    args << "-DOGGTHEORA_theoraenc_LIBRARY=#{Formula["theora"].opt_lib}/libtheoraenc.dylib" # theoraenc
    args << "-DOGGTHEORA_theoradec_LIBRARY=#{Formula["theora"].opt_lib}/libtheoradec.dylib" # theoradec

    # args << "-DPEGTL_DIR=#{Formula["pegtl"]}"

    # args << "-DModule_vtkIOPDAL=ON"

    # args << "-DVTK_CUSTOM_LIBRARY_SUFFIX="
    # args << "-DVTK_INSTALL_INCLUDE_DIR=include/vtk"
    # args << "-DVTK_INSTALL_TCL_DIR=lib/tcl/vtk/"

    args << "-DCMAKE_SKIP_RPATH=ON"
    args << "-DBUILD_DOCUMENTATION=OFF"
    args << "-DDOXYGEN_KEEP_TEMP=ON"
    args << "-DDOCUMENTATION_HTML_HELP=OFF"
    args << "-DDOCUMENTATION_HTML_TARZ=OFF"
    args << "-DBUILD_EXAMPLES=ON"
    args << "-DXDMF_STATIC_AND_SHARED=OFF"

    # args << "-DVTK_USE_TK=ON"
    # args << "-DVTK_USE_EXTERNAL=ON"

    # For MPI4PY

    args << "-DVTK_USE_SYSTEM_MPI4PY=OFF"

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

    # git submodule update --init
    # system "git submodule update --init --recursive"
    # (buildpath/"ThirdParty/vtkm/vtkvtkm/vtk-m").install resource("vtk-m")

    # rm "#{buildpath}/CMake/FindPEGTL.cmake"
    # (buildpath/"CMake/FindPEGTL.cmake").install resource("FindPEGTL")

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

__END__

################################################################################
--- a/Infovis/BoostGraphAlgorithms/vtkBoostGraphAdapter.h
+++ b/Infovis/BoostGraphAlgorithms/vtkBoostGraphAdapter.h
@@ -159,14 +159,14 @@ namespace boost {
     public iterator_facade<vtk_vertex_iterator,
                            vtkIdType,
                            bidirectional_traversal_tag,
-                           vtkIdType,
+                           const vtkIdType&,
                            vtkIdType>
   {
     public:
       explicit vtk_vertex_iterator(vtkIdType i = 0) : index(i) {}

     private:
-      vtkIdType dereference() const { return index; }
+      const vtkIdType& dereference() const { return index; }

       bool equal(const vtk_vertex_iterator& other) const
         { return index == other.index; }
@@ -183,7 +183,7 @@ namespace boost {
     public iterator_facade<vtk_edge_iterator,
                            vtkEdgeType,
                            forward_traversal_tag,
-                           vtkEdgeType,
+                           const vtkEdgeType&,
                            vtkIdType>
   {
     public:
@@ -243,11 +243,16 @@ namespace boost {
             iter = nullptr;
           }
         }
+
+        RecalculateEdge();
       }

     private:
-      vtkEdgeType dereference() const
-        { return vtkEdgeType(vertex, iter->Target, iter->Id); }
+      const vtkEdgeType& dereference() const
+      {
+        assert(iter);
+        return edge;
+      }

       bool equal(const vtk_edge_iterator& other) const
         { return vertex == other.vertex && iter == other.iter; }
@@ -277,6 +282,7 @@ namespace boost {
             inc();
           }
         }
+        RecalculateEdge();
       }

       void inc()
@@ -304,12 +310,21 @@ namespace boost {
         }
       }

+      void RecalculateEdge()
+      {
+        if (iter)
+        {
+          edge = vtkEdgeType(vertex, iter->Target, iter->Id);
+        }
+      }
+
       bool directed;
       vtkIdType vertex;
       vtkIdType lastVertex;
       const vtkOutEdgeType * iter;
       const vtkOutEdgeType * end;
       vtkGraph *graph;
+      vtkEdgeType edge;

       friend class iterator_core_access;
   };
@@ -318,12 +333,12 @@ namespace boost {
     public iterator_facade<vtk_out_edge_pointer_iterator,
                            vtkEdgeType,
                            bidirectional_traversal_tag,
-                           vtkEdgeType,
+                           const vtkEdgeType&,
                            ptrdiff_t>
   {
     public:
       explicit vtk_out_edge_pointer_iterator(vtkGraph *g = 0, vtkIdType v = 0, bool end = false) :
-        vertex(v)
+        vertex(v), iter(nullptr)
       {
         if (g)
         {
@@ -334,19 +349,42 @@ namespace boost {
             iter += nedges;
           }
         }
+        RecalculateEdge();
       }

     private:
-      vtkEdgeType dereference() const { return vtkEdgeType(vertex, iter->Target, iter->Id); }
+      const vtkEdgeType& dereference() const
+      {
+        assert(iter);
+        return edge;
+      }

       bool equal(const vtk_out_edge_pointer_iterator& other) const
       { return iter == other.iter; }

-      void increment() { iter++; }
-      void decrement() { iter--; }
+      void increment()
+      {
+        iter++;
+        RecalculateEdge();
+      }
+
+      void decrement()
+      {
+        iter--;
+        RecalculateEdge();
+      }
+
+      void RecalculateEdge()
+      {
+        if (iter)
+        {
+          edge = vtkEdgeType(vertex, iter->Target, iter->Id);
+        }
+      }

       vtkIdType vertex;
       const vtkOutEdgeType *iter;
+      vtkEdgeType edge;

       friend class iterator_core_access;
   };
@@ -355,12 +393,12 @@ namespace boost {
     public iterator_facade<vtk_in_edge_pointer_iterator,
                            vtkEdgeType,
                            bidirectional_traversal_tag,
-                           vtkEdgeType,
+                           const vtkEdgeType&,
                            ptrdiff_t>
   {
     public:
       explicit vtk_in_edge_pointer_iterator(vtkGraph *g = 0, vtkIdType v = 0, bool end = false) :
-        vertex(v)
+        vertex(v), iter(nullptr)
       {
         if (g)
         {
@@ -371,19 +409,42 @@ namespace boost {
             iter += nedges;
           }
         }
+        RecalculateEdge();
       }

     private:
-      vtkEdgeType dereference() const { return vtkEdgeType(iter->Source, vertex, iter->Id); }
+      const vtkEdgeType& dereference() const
+      {
+        assert(iter);
+        return edge;
+      }

       bool equal(const vtk_in_edge_pointer_iterator& other) const
       { return iter == other.iter; }

-      void increment() { iter++; }
-      void decrement() { iter--; }
+      void increment()
+      {
+        iter++;
+        RecalculateEdge();
+      }
+
+      void decrement()
+      {
+        iter--;
+        RecalculateEdge();
+      }
+
+      void RecalculateEdge()
+      {
+        if (iter)
+        {
+          edge = vtkEdgeType(iter->Source, vertex, iter->Id);
+        }
+      }

       vtkIdType vertex;
       const vtkInEdgeType *iter;
+      vtkEdgeType edge;

       friend class iterator_core_access;
   };
################################################################################


################################################################################
--- a/IO/MySQL/vtkMySQLDatabase.cxx
+++ b/IO/MySQL/vtkMySQLDatabase.cxx
@@ -146,7 +146,7 @@

   if ( this->Reconnect )
   {
-    my_bool recon = true;
+    bool recon = true;
     mysql_options( &this->Private->NullConnection, MYSQL_OPT_RECONNECT, &recon );
   }

--- a/IO/MySQL/vtkMySQLQuery.cxx
+++ b/IO/MySQL/vtkMySQLQuery.cxx
@@ -103,13 +103,13 @@
   }

 public:
-  my_bool           IsNull;      // Is this parameter nullptr?
-  my_bool           IsUnsigned;  // For integer types, is it unsigned?
+  bool              IsNull;      // Is this parameter nullptr?
+  bool              IsUnsigned;  // For integer types, is it unsigned?
   char             *Data;        // Buffer holding actual data
   unsigned long     BufferSize;  // Buffer size
   unsigned long     DataLength;  // Size of the data in the buffer (must
                               // be less than or equal to BufferSize)
-  my_bool           HasError;    // for the server to report truncation
+  bool              HasError;    // for the server to report truncation
   enum enum_field_types  DataType;    // MySQL data type for the contained data
 };
################################################################################


################################################################################
--- a/IO/Movie/CMakeLists.txt
+++ b/IO/Movie/CMakeLists.txt
@@ -33,3 +33,7 @@ vtk_module_library(vtkIOMovie ${Module_SRCS})
 if(WIN32 AND VTK_USE_VIDEO_FOR_WINDOWS)
   vtk_module_link_libraries(vtkIOMovie LINK_PRIVATE vfw32)
 endif()
+
+if(vtkIOMovie_vtkoggtheora)
+  target_link_libraries(vtkIOMovie PUBLIC ogg)
+endif()

# @@ -30,6 +30,8 @@ set(vtkIOMovie_HDRS
#
#  vtk_module_library(vtkIOMovie ${Module_SRCS})
#
# +vtk_module_link_libraries(vtkIOMovie LINK_PRIVATE ogg)
# +
#  if(WIN32 AND VTK_USE_VIDEO_FOR_WINDOWS)
#    vtk_module_link_libraries(vtkIOMovie LINK_PRIVATE vfw32)
#  endif()
################################################################################


################################################################################
--- a/GUISupport/Qt/QVTKOpenGLNativeWidget.cxx
+++ b/GUISupport/Qt/QVTKOpenGLNativeWidget.cxx
@@ -534,10 +534,15 @@ void QVTKOpenGLNativeWidget::paintGL()

   // blit from this->FBO to QOpenGLWidget's FBO.
   vtkQVTKOpenGLNativeWidgetDebugMacro("paintGL::blit-to-defaultFBO");
+#if QT_VERSION < 0x050700
   QOpenGLFunctions_3_2_Core* f =
     QOpenGLContext::currentContext()->versionFunctions<QOpenGLFunctions_3_2_Core>();
+#else
+  QOpenGLFunctions* f = QOpenGLContext::currentContext()->functions();
+#endif
   if (f)
   {
+#if QT_VERSION < 0x050700
     vtkOpenGLState *ostate = this->RenderWindow->GetState();

     f->glBindFramebuffer(GL_DRAW_FRAMEBUFFER, this->defaultFramebufferObject());
@@ -556,6 +561,13 @@ void QVTKOpenGLNativeWidget::paintGL()
     f->glBlitFramebuffer(0, 0, this->RenderWindow->GetSize()[0], this->RenderWindow->GetSize()[1],
       0, 0, this->RenderWindow->GetSize()[0], this->RenderWindow->GetSize()[1], GL_COLOR_BUFFER_BIT,
       GL_NEAREST);
+#else
+    f->glDisable(GL_SCISSOR_TEST); // Scissor affects glBindFramebuffer.
+    QRect rect(0, 0, this->RenderWindow->GetSize()[0], this->RenderWindow->GetSize()[1]);
+    QOpenGLFramebufferObject::blitFramebuffer(0 /* binds to default framebuffer */, rect,
+      this->FBO, rect, GL_COLOR_BUFFER_BIT, GL_NEAREST, GL_COLOR_ATTACHMENT0,
+      GL_COLOR_ATTACHMENT0, QOpenGLFramebufferObject::DontRestoreFramebufferBinding);
+#endif

     // now clear alpha otherwise we end up blending the rendering with
     // background windows in certain cases. It happens on OsX
################################################################################

################################################################################
--- a/ThirdParty/exodusII/vtkexodusII/CMakeLists.txt
+++ b/ThirdParty/exodusII/vtkexodusII/CMakeLists.txt
@@ -297,8 +297,10 @@
   "${CMAKE_CURRENT_BINARY_DIR}/include/exodusII_cfg.h"
   "${CMAKE_CURRENT_BINARY_DIR}/include/exodus_config.h")

-vtk_add_library(vtkexodusII ${sources} ${headers})
+vtk_add_library(vtkexodusII ${sources} ${headers})
+set_property(TARGET vtkexodusII PROPERTY POSITION_INDEPENDENT_CODE ON)
 target_link_libraries(vtkexodusII PUBLIC ${vtknetcdf_LIBRARIES})
+target_link_libraries(vtkexodusII PUBLIC ${vtknetcdf_LIBRARIES} -pthread)
 if (NOT VTK_INSTALL_NO_DEVELOPMENT)
   install(FILES
     ${headers}
################################################################################

################################################################################
--- a/ThirdParty/libharu/vtklibharu/src/CMakeLists.txt
+++ b/ThirdParty/libharu/vtklibharu/src/CMakeLists.txt
@@ -101,8 +101,10 @@
   )
 endif(LIBHPDF_SHARED)
 else ()
-  vtk_add_library(vtklibharu ${LIBHPDF_SRCS})
+  vtk_add_library(vtklibharu ${LIBHPDF_SRCS})
+  set_property(TARGET vtklibharu PROPERTY POSITION_INDEPENDENT_CODE ON)
   target_link_libraries(vtklibharu PRIVATE ${vtkzlib_LIBRARIES} ${vtkpng_LIBRARIES})
+  target_link_libraries(vtklibharu PRIVATE ${vtkzlib_LIBRARIES} ${vtkpng_LIBRARIES} m)
   if (WIN32)
     set_target_properties(vtklibharu
       PROPERTIES
################################################################################


################################################################################
--- a/CMake/FindNetCDF.cmake
+++ b/CMake/FindNetCDF.cmake
@@ -44,7 +44,7 @@ if(NETCDF_USE_DEFAULT_PATHS)
 endif()

 find_path (NETCDF_INCLUDE_DIR netcdf.h
-  PATHS "${NETCDF_DIR}/include")
+  PATHS "${NETCDF_DIR}/include/netcdf")
 mark_as_advanced (NETCDF_INCLUDE_DIR)
 set (NETCDF_C_INCLUDE_DIRS ${NETCDF_INCLUDE_DIR})

@@ -67,7 +67,7 @@ macro (NetCDF_check_interface lang header libs)
     #search starting from user modifiable cache var
     find_path (NETCDF_${lang}_INCLUDE_DIR NAMES ${header}
       HINTS "${NETCDF_INCLUDE_DIR}"
-      HINTS "${NETCDF_${lang}_ROOT}/include"
+      HINTS "${NETCDF_${lang}_ROOT}/include/netcdf"
       ${USE_DEFAULT_PATHS})

     find_library (NETCDF_${lang}_LIBRARY NAMES ${libs}


--- a/Wrapping/PythonCore/CMakeLists.txt
+++ b/Wrapping/PythonCore/CMakeLists.txt
@@ -44,6 +44,7 @@ set(${vtk-module}_INCLUDE_DIRS)

 set(XY ${PYTHON_MAJOR_VERSION}${PYTHON_MINOR_VERSION})
 vtk_module_library(${vtk-module} ${Module_SRCS})
+vtk_module_link_libraries(${vtk-module} LINK_PRIVATE ${PYTHON_LIBRARIES})
 get_property(output_name TARGET ${vtk-module} PROPERTY OUTPUT_NAME)
 string(REPLACE "Python" "Python${XY}" output_name "${output_name}")
 set_property(TARGET ${vtk-module} PROPERTY OUTPUT_NAME ${output_name})
################################################################################


################################################################################
--- a/Wrapping/PythonCore/vtkPythonArgs.cxx
+++ b/Wrapping/PythonCore/vtkPythonArgs.cxx
@@ -124,8 +124,13 @@
 {
   if (PyBytes_Check(o))
   {
+#if PY_VERSION_HEX >= 0x03070000
+    a = const_cast<char *>(PyBytes_AS_STRING(o));
+    return true;
+#else
     a = PyBytes_AS_STRING(o);
     return true;
+#endif
   }
   else if (PyByteArray_Check(o))
   {
@@ -135,7 +140,10 @@
 #ifdef Py_USING_UNICODE
   else if (PyUnicode_Check(o))
   {
-#if PY_VERSION_HEX >= 0x03030000
+#if PY_VERSION_HEX >= 0x03070000
+    a = const_cast<char *>(PyUnicode_AsUTF8(o));
+    return true;
+#elif PY_VERSION_HEX >= 0x03030000
     a = PyUnicode_AsUTF8(o);
     return true;
 #else
################################################################################

################################################################################
--- a/Wrapping/Tools/CMakeLists.txt
+++ b/Wrapping/Tools/CMakeLists.txt
@@ -66,6 +66,7 @@
   target_link_libraries(vtkWrapHierarchy vtkWrappingTools)
   vtk_compile_tools_target(vtkWrapHierarchy)

+if(VTK_WRAP_PYTHON)
   add_executable(vtkWrapPython
     vtkWrapPython.c
     vtkWrapPythonClass.c
@@ -82,12 +83,15 @@
   add_executable(vtkWrapPythonInit vtkWrapPythonInit.c)
   vtk_compile_tools_target(vtkWrapPython)
   vtk_compile_tools_target(vtkWrapPythonInit)
+endif()

+if(VTK_WRAP_JAVA)
   add_executable(vtkParseJava vtkParseJava.c)
   target_link_libraries(vtkParseJava vtkWrappingTools)
   add_executable(vtkWrapJava vtkWrapJava.c)
   target_link_libraries(vtkWrapJava vtkWrappingTools)
   vtk_compile_tools_target(vtkParseJava)
   vtk_compile_tools_target(vtkWrapJava)
+endif()

 endif()

# other
# if(VTK_WRAP_TCL)
#    add_executable(vtkWrapTcl vtkWrapTcl.c)
#    target_link_libraries(vtkWrapTcl vtkWrappingTools)
#    add_executable(vtkWrapTclInit vtkWrapTclInit.c)
#    vtk_compile_tools_target(vtkWrapTcl)
#    vtk_compile_tools_target(vtkWrapTclInit)
# endif()
################################################################################

################################################################################
# --- a/Wrapping/Java/CMakeLists.txt
# +++ b/Wrapping/Java/CMakeLists.txt
# @@ -339,9 +339,9 @@ if(JOGL_GLUE)
#  endif()
#
#  # Set the javac source version
# -set(VTK_JAVA_SOURCE_VERSION "1.6" CACHE STRING "javac source version")
# +set(VTK_JAVA_SOURCE_VERSION "13" CACHE STRING "javac source version")
#  mark_as_advanced(VTK_JAVA_SOURCE_VERSION)
# -set(VTK_JAVA_TARGET_VERSION "1.6" CACHE STRING "javac target version")
# +set(VTK_JAVA_TARGET_VERSION "13" CACHE STRING "javac target version")
#  mark_as_advanced(VTK_JAVA_TARGET_VERSION)
#
#  # On machines with long paths to VTK (or windows where the command line length
################################################################################


################################################################################
--- a/Utilities/Doxygen/CMakeLists.txt
+++ b/Utilities/Doxygen/CMakeLists.txt
@@ -80,7 +80,4 @@
   install(FILES doc_readme.txt
     DESTINATION ${VTK_INSTALL_DOXYGEN_DIR}
     COMPONENT Development)
-  install(DIRECTORY ${VTK_BINARY_DIR}/Utilities/Doxygen/doc/html
-      DESTINATION ${VTK_INSTALL_DOXYGEN_DIR}
-      COMPONENT Development)
 endif()
################################################################################


################################################################################
--- a/CMake/FindLibPROJ.cmake
+++ b/CMake/FindLibPROJ.cmake
@@ -30,7 +30,7 @@ if ( NOT LibPROJ_INCLUDE_DIR OR NOT LibP
   )

   find_path( LibPROJ_INCLUDE_DIR
-    NAMES proj_api.h
+    NAMES proj_api.h proj.h
     HINTS
       ${_LibPROJ_DIR}
       ${_LibPROJ_DIR}/include
--- a/Geovis/Core/vtkGeoProjection.cxx
+++ b/Geovis/Core/vtkGeoProjection.cxx
@@ -72,6 +72,9 @@ public:
   }

   std::map< std::string, std::string > OptionalParameters;
+#if PROJ_VERSION_MAJOR >= 5
+  PJ_PROJ_INFO ProjInfo;
+#endif
 };

 //-----------------------------------------------------------------------------
@@ -80,7 +83,7 @@ int vtkGeoProjection::GetNumberOfProject
   if ( vtkGeoProjectionNumProj < 0 )
   {
     vtkGeoProjectionNumProj = 0;
-    for ( const PJ_LIST* pj = pj_get_list_ref(); pj && pj->id; ++ pj )
+    for ( const PJ_LIST* pj = proj_list_operations(); pj && pj->id; ++ pj )
       ++ vtkGeoProjectionNumProj;
   }
   return vtkGeoProjectionNumProj;
@@ -91,7 +94,7 @@ const char* vtkGeoProjection::GetProject
   if ( projection < 0 || projection >= vtkGeoProjection::GetNumberOfProjections() )
     return nullptr;

-  return pj_get_list_ref()[projection].id;
+  return proj_list_operations()[projection].id;
 }
 //-----------------------------------------------------------------------------
 const char* vtkGeoProjection::GetProjectionDescription( int projection )
@@ -99,7 +102,7 @@ const char* vtkGeoProjection::GetProject
   if ( projection < 0 || projection >= vtkGeoProjection::GetNumberOfProjections() )
     return nullptr;

-  return pj_get_list_ref()[projection].descr[0];
+  return proj_list_operations()[projection].descr[0];
 }
 //-----------------------------------------------------------------------------
 vtkGeoProjection::vtkGeoProjection()
@@ -144,7 +147,7 @@ void vtkGeoProjection::PrintSelf( ostrea
 int vtkGeoProjection::GetIndex()
 {
   int i = 0;
-  for ( const PJ_LIST* proj = pj_get_list_ref(); proj && proj->id; ++ proj, ++ i )
+  for ( const PJ_LIST* proj = proj_list_operations(); proj && proj->id; ++ proj, ++ i )
   {
     if ( ! strcmp( proj->id, this->Name ) )
     {
@@ -161,7 +164,11 @@ const char* vtkGeoProjection::GetDescrip
   {
     return nullptr;
   }
+#if PROJ_VERSION_MAJOR >= 5
+  return this->Internals->ProjInfo.description;
+#else
   return this->Projection->descr;
+#endif
 }
 //-----------------------------------------------------------------------------
 projPJ vtkGeoProjection::GetProjection()
@@ -232,6 +239,9 @@ int vtkGeoProjection::UpdateProjection()
   this->ProjectionMTime = this->GetMTime();
   if ( this->Projection )
   {
+#if PROJ_VERSION_MAJOR >= 5
+    this->Internals->ProjInfo = proj_pj_info(this->Projection);
+#endif
     return 0;
   }
   return 1;
--- a/Geovis/Core/vtkGeoTransform.cxx
+++ b/Geovis/Core/vtkGeoTransform.cxx
@@ -167,9 +167,17 @@ void vtkGeoTransform::InternalTransformP
     double* coord = x;
     for ( vtkIdType i = 0; i < numPts; ++ i )
     {
+#if PROJ_VERSION_MAJOR >= 5
+      xy.x = coord[0]; xy.y = coord[1];
+#else
       xy.u = coord[0]; xy.v = coord[1];
+#endif
       lp = pj_inv( xy, src );
+#if PROJ_VERSION_MAJOR >= 5
+      coord[0] = lp.lam; coord[1] = lp.phi;
+#else
       coord[0] = lp.u; coord[1] = lp.v;
+#endif
       coord += stride;
     }
   }
@@ -191,9 +199,17 @@ void vtkGeoTransform::InternalTransformP
     double* coord = x;
     for ( vtkIdType i = 0; i < numPts; ++ i )
     {
+#if PROJ_VERSION_MAJOR >= 5
+      lp.lam = coord[0]; lp.phi = coord[1];
+#else
       lp.u = coord[0]; lp.v = coord[1];
+#endif
       xy = pj_fwd( lp, dst );
+#if PROJ_VERSION_MAJOR >= 5
+      coord[0] = xy.x; coord[1] = xy.y;
+#else
       coord[0] = xy.u; coord[1] = xy.v;
+#endif
       coord += stride;
     }
   }
--- a/ThirdParty/libproj/vtk_libproj.h.in
+++ b/ThirdParty/libproj/vtk_libproj.h.in
@@ -15,10 +15,20 @@
 #ifndef vtk_libproj_h
 #define vtk_libproj_h

+#define VTK_LibPROJ_MAJOR_VERSION @LibPROJ_MAJOR_VERSION@
+
 /* Use the libproj library configured for VTK.  */
 #cmakedefine VTK_USE_SYSTEM_LIBPROJ
 #ifdef VTK_USE_SYSTEM_LIBPROJ
-# include <projects.h>
+# if VTK_LibPROJ_MAJOR_VERSION >= 5
+#  include <proj.h>
+# endif
+# if VTK_LibPROJ_MAJOR_VERSION < 6
+#  include <projects.h>
+# endif
+# if VTK_LibPROJ_MAJOR_VERSION >= 6
+#  define ACCEPT_USE_OF_DEPRECATED_PROJ_API_H 1
+# endif
 # include <proj_api.h>
 # include <geodesic.h>
 #else
--- VTK-8.2.0/CMake/FindLibPROJ.cmake	2019-09-11 22:13:29.493741215 -0600
+++ vtk/CMake/FindLibPROJ.cmake	2019-09-11 19:56:57.465802610 -0600
@@ -1,55 +1,67 @@
-# Find LibPROJ library and header file
-# Sets
-#   LibPROJ_FOUND       to 0 or 1 depending on the result
-#   LibPROJ_INCLUDE_DIR to directories required for using libproj4
-#   LibPROJ_LIBRARIES   to libproj4 and any dependent libraries
-# If LibPROJ_REQUIRED is defined, then a fatal error message will be generated if libproj4 is not found
-
-if ( NOT LibPROJ_INCLUDE_DIR OR NOT LibPROJ_LIBRARIES OR NOT LibPROJ_FOUND )
+find_path(LibPROJ_INCLUDE_DIR
+  NAMES proj_api.h proj.h
+  DOC "libproj include directories")
+mark_as_advanced(LibPROJ_INCLUDE_DIR)

-  if ( $ENV{LibPROJ_DIR} )
-    file( TO_CMAKE_PATH "$ENV{LibPROJ_DIR}" _LibPROJ_DIR )
+find_library(LibPROJ_LIBRARY_RELEASE
+  NAMES proj
+  DOC "libproj release library")
+mark_as_advanced(LibPROJ_LIBRARY_RELEASE)
+
+find_library(LibPROJ_LIBRARY_DEBUG
+  NAMES projd
+  DOC "libproj debug library")
+mark_as_advanced(LibPROJ_LIBRARY_DEBUG)
+
+include(SelectLibraryConfigurations)
+select_library_configurations(LibPROJ)
+
+if (LibPROJ_INCLUDE_DIR)
+  if (EXISTS "${LibPROJ_INCLUDE_DIR}/proj.h")
+    file(STRINGS "${LibPROJ_INCLUDE_DIR}/proj.h" _libproj_version_lines REGEX "#define[ \t]+PROJ_VERSION_(MAJOR|MINOR|PATCH)")
+    string(REGEX REPLACE ".*PROJ_VERSION_MAJOR *\([0-9]*\).*" "\\1" _libproj_version_major "${_libproj_version_lines}")
+    string(REGEX REPLACE ".*PROJ_VERSION_MINOR *\([0-9]*\).*" "\\1" _libproj_version_minor "${_libproj_version_lines}")
+    string(REGEX REPLACE ".*PROJ_VERSION_PATCH *\([0-9]*\).*" "\\1" _libproj_version_patch "${_libproj_version_lines}")
+  else ()
+    file(STRINGS "${LibPROJ_INCLUDE_DIR}/proj_api.h" _libproj_version_lines REGEX "#define[ \t]+PJ_VERSION")
+    string(REGEX REPLACE ".*PJ_VERSION *\([0-9]*\).*" "\\1" _libproj_version "${_libproj_version_lines}")
+    math(EXPR _libproj_version_major "${_libproj_version} / 100")
+    math(EXPR _libproj_version_minor "(${_libproj_version} % 100) / 10")
+    math(EXPR _libproj_version_patch "${_libproj_version} % 10")
   endif ()
-
-  set(LibPROJ_LIBRARY_SEARCH_PATHS
-    ${_LibPROJ_DIR}
-    ${_LibPROJ_DIR}/lib64
-    ${_LibPROJ_DIR}/lib
-  )
-
-  find_library( LibPROJ_LIBRARY_RELEASE
-    NAMES proj
-    HINTS
-      ${LibPROJ_LIBRARY_SEARCH_PATHS}
-  )
-
-  find_library( LibPROJ_LIBRARY_DEBUG
-    NAMES projd
-    PATHS
-      ${LibPROJ_LIBRARY_SEARCH_PATHS}
-  )
-
-  find_path( LibPROJ_INCLUDE_DIR
-    NAMES proj_api.h proj.h
-    HINTS
-      ${_LibPROJ_DIR}
-      ${_LibPROJ_DIR}/include
-  )
-
-  include(SelectLibraryConfigurations)
-  select_library_configurations(LibPROJ)
-
-  include(FindPackageHandleStandardArgs)
-  find_package_handle_standard_args(LibPROJ
-                                    REQUIRED_VARS LibPROJ_LIBRARY LibPROJ_INCLUDE_DIR)
-
-  if(LibPROJ_FOUND)
-    set(LibPROJ_INCLUDE_DIRS ${LibPROJ_INCLUDE_DIR})
-
-    if(NOT LibPROJ_LIBRARIES)
-      set(LibPROJ_LIBRARIES ${LibPROJ_LIBRARY})
-    endif()
-  endif()
+  set(LibPROJ_VERSION "${_libproj_version_major}.${_libproj_version_minor}.${_libproj_version_patch}")
+  set(LibPROJ_MAJOR_VERSION "${_libproj_version_major}")
+  unset(_libproj_version_major)
+  unset(_libproj_version_minor)
+  unset(_libproj_version_patch)
+  unset(_libproj_version)
+  unset(_libproj_version_lines)
 endif ()

-mark_as_advanced(LibPROJ_INCLUDE_DIR)
+include(FindPackageHandleStandardArgs)
+find_package_handle_standard_args(LibPROJ
+  REQUIRED_VARS LibPROJ_LIBRARY LibPROJ_INCLUDE_DIR
+  VERSION_VAR LibPROJ_VERSION)
+
+if (LibPROJ_FOUND)
+  set(LibPROJ_INCLUDE_DIRS "${LibPROJ_INCLUDE_DIR}")
+  set(LibPROJ_LIBRARIES "${LibPROJ_LIBRARY}")
+
+  if (NOT TARGET LibPROJ::LibPROJ)
+    add_library(LibPROJ::LibPROJ UNKNOWN IMPORTED)
+    set_target_properties(LibPROJ::LibPROJ PROPERTIES
+      INTERFACE_INCLUDE_DIRECTORIES "${LibPROJ_INCLUDE_DIR}")
+    if (LibPROJ_LIBRARY_RELEASE)
+      set_property(TARGET LibPROJ::LibPROJ APPEND PROPERTY
+        IMPORTED_CONFIGURATIONS RELEASE)
+      set_target_properties(LibPROJ::LibPROJ PROPERTIES
+        IMPORTED_LOCATION_RELEASE "${LibPROJ_LIBRARY_RELEASE}")
+    endif ()
+    if (LibPROJ_LIBRARY_DEBUG)
+      set_property(TARGET LibPROJ::LibPROJ APPEND PROPERTY
+        IMPORTED_CONFIGURATIONS DEBUG)
+      set_target_properties(LibPROJ::LibPROJ PROPERTIES
+        IMPORTED_LOCATION_DEBUG "${LibPROJ_LIBRARY_DEBUG}")
+    endif ()
+  endif ()
+endif ()
################################################################################


################################################################################
--- a/Utilities/PythonInterpreter/vtkPythonStdStreamCaptureHelper.h
+++ b/Utilities/PythonInterpreter/vtkPythonStdStreamCaptureHelper.h
@@ -140,6 +140,12 @@ static PyTypeObject vtkPythonStdStreamCaptureHelperType = {
 #if PY_VERSION_HEX >= 0x03040000
   0, // tp_finalize
 #endif
+#if PY_VERSION_HEX >= 0x03080000
+  0, // tp_vectorcall
+#if PY_VERSION_HEX < 0x03090000
+  0, // tp_print
+#endif
+#endif
 };

 static PyObject* vtkWrite(PyObject* self, PyObject* args)

--- a/Wrapping/PythonCore/PyVTKMethodDescriptor.cxx
+++ b/Wrapping/PythonCore/PyVTKMethodDescriptor.cxx
@@ -186,7 +186,7 @@ PyTypeObject PyVTKMethodDescriptor_Type = {
   sizeof(PyMethodDescrObject),           // tp_basicsize
   0,                                     // tp_itemsize
   PyVTKMethodDescriptor_Delete,          // tp_dealloc
-  nullptr,                               // tp_print
+  0,                                     // tp_vectorcall_offset
   nullptr,                               // tp_getattr
   nullptr,                               // tp_setattr
   nullptr,                               // tp_compare

--- a/Wrapping/PythonCore/PyVTKNamespace.cxx
+++ b/Wrapping/PythonCore/PyVTKNamespace.cxx
@@ -49,7 +49,7 @@ PyTypeObject PyVTKNamespace_Type = {
   0,                                     // tp_basicsize
   0,                                     // tp_itemsize
   PyVTKNamespace_Delete,                 // tp_dealloc
-  nullptr,                               // tp_print
+  0,                                     // tp_vectorcall_offset
   nullptr,                               // tp_getattr
   nullptr,                               // tp_setattr
   nullptr,                               // tp_compare

--- a/Wrapping/PythonCore/PyVTKReference.cxx
+++ b/Wrapping/PythonCore/PyVTKReference.cxx
@@ -1010,7 +1010,7 @@ PyTypeObject PyVTKReference_Type = {
   sizeof(PyVTKReference),                // tp_basicsize
   0,                                     // tp_itemsize
   PyVTKReference_Delete,                 // tp_dealloc
-  nullptr,                               // tp_print
+  0,                                     // tp_vectorcall_offset
   nullptr,                               // tp_getattr
   nullptr,                               // tp_setattr
   nullptr,                               // tp_compare
@@ -1067,7 +1067,7 @@ PyTypeObject PyVTKNumberReference_Type = {
   sizeof(PyVTKReference),                // tp_basicsize
   0,                                     // tp_itemsize
   PyVTKReference_Delete,                 // tp_dealloc
-  nullptr,                               // tp_print
+  0,                                     // tp_vectorcall_offset
   nullptr,                               // tp_getattr
   nullptr,                               // tp_setattr
   nullptr,                               // tp_compare
@@ -1124,7 +1124,7 @@ PyTypeObject PyVTKStringReference_Type = {
   sizeof(PyVTKReference),                // tp_basicsize
   0,                                     // tp_itemsize
   PyVTKReference_Delete,                 // tp_dealloc
-  nullptr,                               // tp_print
+  0,                                     // tp_vectorcall_offset
   nullptr,                               // tp_getattr
   nullptr,                               // tp_setattr
   nullptr,                               // tp_compare
@@ -1181,7 +1181,7 @@ PyTypeObject PyVTKTupleReference_Type = {
   sizeof(PyVTKReference),                // tp_basicsize
   0,                                     // tp_itemsize
   PyVTKReference_Delete,                 // tp_dealloc
-  nullptr,                               // tp_print
+  0,                                     // tp_vectorcall_offset
   nullptr,                               // tp_getattr
   nullptr,                               // tp_setattr
   nullptr,                               // tp_compare

--- a/Wrapping/PythonCore/PyVTKTemplate.cxx
+++ b/Wrapping/PythonCore/PyVTKTemplate.cxx
@@ -268,7 +268,7 @@ PyTypeObject PyVTKTemplate_Type = {
   0,                                     // tp_basicsize
   0,                                     // tp_itemsize
   nullptr,                               // tp_dealloc
-  nullptr,                               // tp_print
+  0,                                     // tp_vectorcall_offset
   nullptr,                               // tp_getattr
   nullptr,                               // tp_setattr
   nullptr,                               // tp_compare

--- a/Wrapping/PythonCore/vtkPythonCompatibility.h
+++ b/Wrapping/PythonCore/vtkPythonCompatibility.h
@@ -64,7 +64,13 @@
 #endif

 // PyTypeObject compatibility
-#if PY_VERSION_HEX >= 0x03040000
+#if PY_VERSION_HEX >= 0x03090000
+#define VTK_WRAP_PYTHON_SUPPRESS_UNINITIALIZED \
+  0, 0, 0, 0,
+#elif PY_VERSION_HEX >= 0x03080000
+#define VTK_WRAP_PYTHON_SUPPRESS_UNINITIALIZED \
+  0, 0, 0, 0, 0,
+#elif PY_VERSION_HEX >= 0x03040000
 #define VTK_WRAP_PYTHON_SUPPRESS_UNINITIALIZED \
   0, 0, 0,
 #else

--- a/Wrapping/Tools/vtkWrapPythonClass.c
+++ b/Wrapping/Tools/vtkWrapPythonClass.c
@@ -521,7 +521,7 @@ void vtkWrapPython_GenerateObjectType(
     "  sizeof(PyVTKObject), // tp_basicsize\n"
     "  0, // tp_itemsize\n"
     "  PyVTKObject_Delete, // tp_dealloc\n"
-    "  nullptr, // tp_print\n"
+    "  0, // tp_vectorcall_offset\n"
     "  nullptr, // tp_getattr\n"
     "  nullptr, // tp_setattr\n"
     "  nullptr, // tp_compare\n"

--- a/Wrapping/Tools/vtkWrapPythonEnum.c
+++ b/Wrapping/Tools/vtkWrapPythonEnum.c
@@ -145,7 +145,7 @@ void vtkWrapPython_GenerateEnumType(
     "  sizeof(PyIntObject), // tp_basicsize\n"
     "  0, // tp_itemsize\n"
     "  nullptr, // tp_dealloc\n"
-    "  nullptr, // tp_print\n"
+    "  0, // tp_vectorcall_offset\n"
     "  nullptr, // tp_getattr\n"
     "  nullptr, // tp_setattr\n"
     "  nullptr, // tp_compare\n"

--- a/Wrapping/Tools/vtkWrapPythonType.c
+++ b/Wrapping/Tools/vtkWrapPythonType.c
@@ -709,7 +709,7 @@ void vtkWrapPython_GenerateSpecialType(
     "  sizeof(PyVTKSpecialObject), // tp_basicsize\n"
     "  0, // tp_itemsize\n"
     "  Py%s_Delete, // tp_dealloc\n"
-    "  nullptr, // tp_print\n"
+    "  0, // tp_vectorcall_offset\n"
     "  nullptr, // tp_getattr\n"
     "  nullptr, // tp_setattr\n"
     "  nullptr, // tp_compare\n"
################################################################################


################################################################################
# --- a/IO/GDAL/vtkGDALVectorReader.cxx
# +++ b/IO/GDAL/vtkGDALVectorReader.cxx
# @@ -44,7 +44,7 @@ class vtkGDALVectorReader::Internal
#  public:
#    Internal( const char* srcName, int srcMode, int appendFeatures, int addFeatIds )
#      {
# -    this->Source = OGRSFDriverRegistrar::Open( srcName, srcMode, &this->Driver );
# +    this->Source = (GDALDataset*) OGROpen( srcName, srcMode, NULL );
#      if ( ! this->Source )
#        {
#        this->LastError = CPLGetLastErrorMsg();
# @@ -61,7 +61,7 @@ public:
#      {
#      if ( this->Source )
#        {
# -      OGRDataSource::DestroyDataSource( this->Source );
# +      GDALClose( (GDALDatasetH) this->Source );
#        }
#      }
#
# @@ -304,7 +304,7 @@ public:
#      return nCells;
#      }
#
# -  OGRDataSource* Source;
# +  GDALDataset* Source;
#    OGRSFDriver* Driver;
#    const char* LastError;
#    int LayerIdx;
################################################################################

################################################################################
# --- a/ThirdParty/libxml2/vtklibxml2/threads.c
# +++ b/ThirdParty/libxml2/vtklibxml2/threads.c
# @@ -49,7 +49,7 @@
#  #ifdef HAVE_PTHREAD_H
#
#  static int libxml_is_threaded = -1;
# -#ifdef __GNUC__
# +#if 0
#  #ifdef linux
#  #if (__GNUC__ == 3 && __GNUC_MINOR__ >= 3) || (__GNUC__ > 3)
#  extern int pthread_once (pthread_once_t *__once_control,
################################################################################
