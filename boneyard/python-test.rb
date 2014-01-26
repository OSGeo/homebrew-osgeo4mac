require 'formula'

class PythonTest < Formula
  homepage 'http://qgis.dakotacarto.com/'
  url 'http://qgis.dakotacarto.com/osgeo4mac/dummy_1.0.tar.gz'
  sha1 '1320ca8ec89aca7ab649a1c95e3e1d9deb15a147'

  depends_on :python

  def install
    puts "which python:        " + %x(which python).strip
    puts "which python-config: " + %x(which python-config).strip
    puts "sys.prefix:          " + %x(python -c "import sys; print(sys.prefix)").strip

    odie 'bye'
  end

  def caveats;<<-EOS.undent

    Just a test of Homebrew Python setup.

    EOS
  end
end
