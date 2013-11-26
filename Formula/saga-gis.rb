require 'formula'

class SagaGis < Formula
  homepage 'http://www.saga-gis.org'
  url 'http://downloads.sourceforge.net/project/saga-gis/SAGA%20-%202.1/SAGA%202.1.0/saga_2.1.0.tar.gz'
  sha1 '1da4d7aed8ceb9efab9698b2c3bdb2670e65c5dd'

  option 'disable-gui', "Build the command line version of saga-gis (saga_cmd) only"
  option 'enable-python', "Build pythong bindings for saga-gis"

  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'libtool' => :build
  
  depends_on 'geos'
  depends_on 'gdal'
  depends_on 'proj'
  depends_on 'jasper'
  depends_on 'fftw'
  depends_on 'unixodbc'
  depends_on 'wxmac'

  def patches
    {:p0 => "https://gist.github.com/jctull/6f85de4211b499f1d117/raw/28de4ba6f1a99ecc207d31927d48646f65296dec/saga-gis.patch"}
  end

  def install
    cxxstdlib_check :skip
    args = [
      "--disable-openmp",
      "--prefix=#{prefix}"
    ]
    args << "--disable-gui" if build.include? 'disable-gui'
    args << "--enable-python" if build.include? 'enable-python'
    system "./configure", *args
    system "make", "install"
  end
  
  test do
    system "#{bin}/saga_cmd", "-v"
  end
end
