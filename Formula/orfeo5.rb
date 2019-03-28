class Orfeo5 < Formula
  desc "Library of image processing algorithms"
  homepage "https://www.orfeo-toolbox.org/otb/"

  stable do
    url "https://github.com/orfeotoolbox/OTB/archive/5.10.1.tar.gz"
    sha256 "01b40747f0afba51af1aa5e696a7205c2177b0f99f5208d9db8369acc984fe39"

    # Patch to fix OSSIM adaptor compilation
    patch :DATA
  end

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    cellar :any
    rebuild 1
    sha256 "d9a2e74ea28e4d2d2c87cac68852e5e96b8c31bfea682df22e196a572b24136b" => :high_sierra
    sha256 "d9a2e74ea28e4d2d2c87cac68852e5e96b8c31bfea682df22e196a572b24136b" => :sierra
  end

  option "without-monteverdi", "Build without Monteverdi and Mapla applications (Qt4 required)"
  option "with-iceviewer", "Build with ICE Viewer application (Qt4 and X11 required)"
  option "with-examples", "Compile and install various examples"
  option "with-java", "Enable Java support"

  depends_on "cmake" => :build

  # required
  depends_on "boost"
  depends_on "osgeo-vtk"
  depends_on "brewsci/science/insighttoolkit"
  depends_on "osgeo-libgeotiff"
  depends_on "libpng"
  depends_on "pcre"
  depends_on "openssl"
  depends_on "ossim@2.1"
  depends_on "sqlite"
  depends_on "tinyxml"
  depends_on "open-scene-graph" # (for libOpenThreads, now internal to osg)
  depends_on "zlib"
  depends_on "qwt-qt4@5.2"

  # recommended
  depends_on "muparser" => :recommended
  depends_on "libkml" => :recommended
  depends_on "libsvm" => :recommended
  depends_on "minizip" => :recommended

  # optional
  depends_on "python@2" => :optional
  depends_on "swig" if build.with? "python@2"
  depends_on "fftw" => :optional # restricts built binaries to GPL license
  depends_on "mapnik" => :optional
  depends_on "brewsci/science/opencv" => :optional
  depends_on "openjpeg" => :optional
  depends_on "open-mpi" => :optional
  depends_on "brewsci/science/shark" => :optional

  # ICE Viewer: needs X11 support
  # apparently, GLUT is not needed by Monteverdi, which uses ICE non-gui module,
  # but is needed for the ICE Viewer
  depends_on "freeglut" if build.with? "iceviewer"

  # Monteverdi: required deps and required/optionals shared with OTB
  if build.with? "monteverdi"
    depends_on "gdal2"
    depends_on "glew"
    depends_on "glfw"
    depends_on "qt-4"
    depends_on "qwt-qt4@5.2"
  else
    depends_on "gdal2" => :recommended
    depends_on "glew" => :optional
    depends_on "glfw" => :optional
    depends_on "qt-4" => :optional
  end

  resource "geoid" do
    # geoid to use in elevation calculations, if no DEM defined or avialable
    url "https://gitlab.orfeo-toolbox.org/orfeotoolbox/otb-data/raw/master/Input/DEM/egm96.grd"
    sha256 "2babe341e8e04db11447e823ac0dfe4b17f37fd24c7966bb6aeab85a30d9a733"
    version "5.0.0"
  end

  def install
    (libexec/"default_geoid").install resource("geoid")

    args = std_cmake_args + %W[
      -DOTB_BUILD_DEFAULT_MODULES=ON
      -DBUILD_TESTING=OFF
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_MACOSX_RPATH=OFF
      -DCMAKE_CXX_STANDARD=11
      -DQWT_LIB=#{Formula['qwt-qt4@5.2'].lib}
      -DQWT_INCLUDE_DIR=#{Formula['qwt-qt4@5.2'].include}
    ]

    ENV.cxx11

    if build.with? "iceviewer"
      fg = Formula["freeglut"]
      args << "-DGLUT_INCLUDE_DIR=#{fg.opt_include}"
      args << "-DGLUT_glut_LIBRARY=#{fg.opt_lib}/libglut.dylib"
    end

    args << "-DBUILD_EXAMPLES=" + (build.with?("examples") ? "ON" : "OFF")
    # args << "-DOTB_USE_PATENTED=" + (build.with?("patented") ? "ON" : "OFF")
    args << "-DOTB_WRAP_JAVA=" + (build.with?("java") ? "ON" : "OFF")
    args << "-DOTB_WRAP_PYTHON=OFF" if build.without? "python@2"
    args << "-DITK_USE_FFTWF=" + (build.with?("fftw") ? "ON" : "OFF")
    args << "-DITK_USE_FFTWD=" + (build.with?("fftw") ? "ON" : "OFF")
    args << "-DITK_USE_SYSTEM_FFTW=" + (build.with?("fftw") ? "ON" : "OFF")

    args << "-DOTB_USE_CURL=ON"
    args << "-DOTB_USE_GLEW=" + ((build.with?("glew") || build.with?("monteverdi")) ? "ON" : "OFF")
    args << "-DOTB_USE_GLFW=" + ((build.with?("glfw") || build.with?("monteverdi")) ? "ON" : "OFF")
    args << "-DOTB_USE_GLUT=" + (build.with?("iceviewer") ? "ON" : "OFF")
    args << "-DOTB_USE_LIBKML=" + (build.with?("libkml") ? "ON" : "OFF")
    args << "-DOTB_USE_LIBSVM=" + (build.with?("libsvm") ? "ON" : "OFF")
    args << "-DOTB_USE_MAPNIK=" + (build.with?("mapnik") ? "ON" : "OFF")
    args << "-DOTB_USE_MUPARSER=" + (build.with?("muparser") ? "ON" : "OFF")
    # args << "-DOTB_USE_MUPARSERX=" + (build.with?("") ? "ON" : "OFF")
    args << "-DOTB_USE_OPENCV=" + (build.with?("opencv") ? "ON" : "OFF")
    args << "-DOTB_USE_OPENGL=" + ((build.with?("examples") || build.with?("iceviewer") || build.with?("monteverdi")) ? "ON" : "OFF")
    args << "-DOTB_USE_MPI=" + (build.with?("mpi") ? "ON" : "OFF")
    args << "-DOTB_USE_OPENJPEG=" + (build.with?("openjpeg") ? "ON" : "OFF")
    args << "-DOTB_USE_QT4=" + ((build.with?("qt-4") || build.with?("monteverdi")) ? "ON" : "OFF")
    args << "-DOTB_USE_QWT=" + ((build.with?("qt-4") || build.with?("monteverdi")) ? "ON" : "OFF")
    args << "-DOTB_USE_SIFTFAST=ON"
    args << "-DOTB_USE_SHARK=" + (build.with?("brewsci/science/shark") ? "ON" : "OFF")

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end

    # clean up any unneeded otbgui script wrappers
    rm_f Dir["#{bin}/otbgui*"] unless (bin/"otbgui").exist?

    # make env-wrapped command line utility launcher scripts
    envars = {
      :GDAL_DATA => "#{Formula["gdal2"].opt_share}/gdal",
      :OTB_APPLICATION_PATH => "#{opt_lib}/otb/applications",
    }
    bin.env_script_all_files(libexec/"bin", envars)
  end

  def caveats; <<~EOS
      The default geoid to use in elevation calculations is available in:

        #{opt_libexec}/default_geoid/egm96.grd

  EOS
  end

  test do
    puts "Testing CLI wrapper"
    out = `#{opt_bin}/otbcli 2>&1`
    assert_match "module_name [MODULEPATH] [arguments]", out
    puts "Testing Rescale CLI app"
    out = `#{opt_bin}/otbcli_Rescale 2>&1`
    assert_match "Rescale the image between two given values", out
    if (opt_bin/"otbgui").exist?
      puts "Testing Qt GUI wrapper"
      out = `#{opt_bin}/otbgui 2>&1`
      assert_match "module_name [module_path]", out
    end
  end
end

__END__
diff --git a/Modules/Adapters/OSSIMAdapters/src/otbRPCSolverAdapter.cxx b/Modules/Adapters/OSSIMAdapters/src/otbRPCSolverAdapter.cxx
index d20e208..92796dd 100644
--- a/Modules/Adapters/OSSIMAdapters/src/otbRPCSolverAdapter.cxx
+++ b/Modules/Adapters/OSSIMAdapters/src/otbRPCSolverAdapter.cxx
@@ -109,7 +109,8 @@ RPCSolverAdapter::Solve(const GCPsContainerType& gcpContainer,
   rmsError = rpcSolver->getRmsError();

   // Retrieve the output RPC projection
-  ossimRefPtr<ossimRpcProjection> rpcProjection = dynamic_cast<ossimRpcProjection*>(rpcSolver->createRpcProjection()->getProjection());
+  ossimRefPtr<ossimImageGeometry> outputProj = dynamic_cast<ossimImageGeometry*>(rpcSolver->createRpcProjection());
+  ossimRefPtr<ossimRpcProjection> rpcProjection = dynamic_cast<ossimRpcProjection*>(outputProj->getProjection());

   // Export the sensor model in an ossimKeywordlist
   ossimKeywordlist geom_kwl;
