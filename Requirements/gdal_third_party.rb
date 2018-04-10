class GdalThirdParty < Requirement
  fatal true

  satisfy do
    envar = ENV['GDAL_THIRD_PARTY']
    envar && File.exists?(envar)
  end

  def message; <<~EOS
    Define GDAL_THIRD_PARTY environment variable that points to a directory,
    which contains the unaltered download archive of the third-party library:

      `export GDAL_THIRD_PARTY=/path/to/gdal/third-party/directory`

  EOS
  end
end