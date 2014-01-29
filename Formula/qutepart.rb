require "formula"

class Qutepart < Formula
  homepage "https://github.com/hlamer/qutepart"
  url "https://github.com/hlamer/qutepart/archive/v1.1.1.tar.gz"
  sha1 "0be6bd7dd4d0d770046b038d0e630bd6c42016ce"

  depends_on :python
  depends_on "pyqt"
  depends_on "pcre"

  def install
    ENV.deparallelize
    args = %W[
        --prefix=#{prefix}
        --lib-dir=#{HOMEBREW_PREFIX/"lib"}
        --include-dir=#{HOMEBREW_PREFIX/"include"}
    ]
    system "python", "setup.py", "install", *args
    prefix.install "editor.py"
    rm "todo.txt"
  end

  test do
    assert_equal "(#{version.to_s.gsub(".", ", ")})",
                 %x(python -c 'import qutepart;print qutepart.VERSION').strip
  end
end
