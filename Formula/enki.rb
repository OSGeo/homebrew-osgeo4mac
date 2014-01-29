require "formula"

class Enki < Formula
  homepage "http://enki-editor.org/"
  url "https://github.com/hlamer/enki/archive/v13.11.1.tar.gz"
  sha1 "2bcf6bb14550b07c5a227a5525834aa28849fb59"

  depends_on :python
  depends_on "pyqt"
  depends_on "qutepart"
  depends_on "ctags" => :recommended
  depends_on "pyparsing" => [:python]
  depends_on "markdown" => [:python]
  depends_on "docutils" => [:python]

  def install
    ENV.deparallelize
    system "python", "setup.py", "install", "--prefix=#{prefix}"
  end

  test do
    assert_equal %x(enki --version).strip, "enki #{version}"
  end
end
