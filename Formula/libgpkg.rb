require 'formula'

class RubyVersion19 < Requirement
  fatal true
  satisfy(:build_env => false) { RUBY_VERSION >= '1.9' }

  def message; <<-EOS.undent
      Ruby >= 1.9 is required to run tests, which utilize Encoding class.
      Install without `--run-tests` option.

    EOS
  end
end

class Libgpkg < Formula
  homepage 'https://bitbucket.org/luciad/libgpkg'
  head 'https://bitbucket.org/luciad/libgpkg', :using => :hg, :branch => 'default'

  option 'run-tests', 'Run unit tests before installation'

  depends_on 'cmake' => :build
  depends_on 'geos' => :recommended
  if build.include? 'run-tests'
    depends_on RubyVersion19
    depends_on 'bundler' => :ruby
  end

  def install
    args = std_cmake_args
    args << '-DGPKG_GEOS=ON' unless build.without? 'geos'
    args << '-DGPKG_TEST=ON' if build.include? 'run-tests'

    File.open('gpkg/CMakeLists.txt', 'a') do |f|
      f.write <<-EOS.undent

      if(APPLE)
        set_target_properties(gpkg_ext PROPERTIES SUFFIX ".dylib")
      endif()

      INSTALL(TARGETS gpkg_static gpkg_ext DESTINATION lib)
      INSTALL(FILES gpkg.h DESTINATION include)
      if(GPKG_HAVE_GEOM_FUNC)
        INSTALL(TARGETS gpkg_geom DESTINATION lib)
      endif()
      EOS
    end

    mkdir 'build' do
      system 'cmake', '..', *args
      system 'make install'
      rm lib/'gpkg.h' # extraneous header from lib install
      system 'make test' if build.include? 'run-tests'
    end
  end

  def caveats; <<-EOS.undent
    Custom SQLite command-line shell that autoloads static GeoPackage extension:
      #{opt_prefix}/bin/gpkg

    Make sure to review Usage (extension loading) and Function Reference docs:
      https://bitbucket.org/luciad/libgpkg/wiki/Home

  EOS
  end
end
