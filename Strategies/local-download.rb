class LocalDownloadStrategyError < RuntimeError
  def initialize
    message = <<-EOS.undent
    Define OSGEO4MAC_LOCAL_ARCHIVE environment variable that points to a
    directory, which contains the unaltered, already-downloaded archive(s):

      export OSGEO4MAC_LOCAL_ARCHIVE=/path/to/directory/of/archives
    EOS
    super message
  end
end

class LocalDownloadStrategy < CurlDownloadStrategy
  def fetch
    ldls = ENV["OSGEO4MAC_LOCAL_ARCHIVE"]
    raise LocalDownloadStrategyError unless ldls && File.directory?(ldls)
    @url = @url.sub(/(.*)/, "file://#{ldls}/\\1")
    super
  end
end
