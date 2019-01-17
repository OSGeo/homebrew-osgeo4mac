class Whitebox < Formula
  desc "Geographic information system (GIS) and remote sensing package intended for advanced geospatial analysis and data visualization"
  homepage "https://www.uoguelph.ca/~hydrogeo/Whitebox"
  url "https://www.uoguelph.ca/~hydrogeo/Whitebox/WhiteboxGAT-mac.zip"
  sha256 "32b2a75dab883e97d271621c60e7ad254558587b8bda0f1013bb9562077eea34"
  # url "https://github.com/jblindsay/whitebox-geospatial-analysis-tools.git",
  #   :branch => "master",
  #   :commit => "57d26067d2cf2e30ecc150c04e7b5342525ac9d9"
  version "3.4.0"

  # revision 1

  # head "https://github.com/jblindsay/whitebox-geospatial-analysis-tools.git", :branch => "master"

  option "with-app", "Build WBT.app Package"

  depends_on "bash"
  # depends_on :java

  def install

    printf "\n\033[31mRequires Java 8.\e[0m\n\n"

    printf "\e[0mHow To Install Java 8:\n\n"

    printf "\e[32mhttps://gist.github.com/ntamvl/5f4dbaa8f68e6897b99682a395a44c2e\e[0m\n"

    printf "\e[32mhttps://gist.github.com/alChaCC/ddb11542c9e6b6683bad80d9ca858bc5\e[0m\n\n"

    cp_r "#{buildpath}", "#{prefix}"

    mkdir "#{bin}"

    # create whitebox
    File.open("#{bin}/whitebox", "w") { |file|
      file << '#!/bin/sh'
      file << "\n"
      file << "/usr/bin/java -jar #{prefix}/WhiteboxGAT-mac/WhiteboxGIS.jar"
    }

    # chmod("+x", "#{bin}/whitebox")

    if build.with? "app"
      (prefix/"WBT.app/Contents/PkgInfo").write "APPLWBT"

      (prefix/"WBT.app/Contents/Resources").mkpath

      cp_r "#{prefix}/WhiteboxGAT-mac/resources/Images/wbGAT.png", "#{prefix}/WBT.app/Contents/Resources/whitebox.icns"

      config = <<~EOS
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleDevelopmentRegion</key>
          <string>English</string>
          <key>CFBundleExecutable</key>
          <string>whitebox</string>
          <key>CFBundleIconFile</key>
          <string>whitebox.icns</string>
          <key>CFBundleInfoDictionaryVersion</key>
          <string>6.0</string>
          <key>CFBundleName</key>
          <string>WTB</string>
          <key>CFBundlePackageType</key>
          <string>APPL</string>
          <key>CFBundleSignature</key>
          <string>WTB</string>
          <key>CFBundleVersion</key>
          <string>1.0</string>
          <key>CSResourcesFileMapped</key>
          <true/>
          <key>NSHighResolutionCapable</key>
          <string>True</string>
        </dict>
        </plist>
      EOS

      (prefix/"WBT.app/Contents/Info.plist").write config

      chdir "#{prefix}/WBT.app/Contents" do
        mkdir "MacOS" do
          ln_s "#{bin}/whitebox", "whitebox"
        end
      end
    end
  end

  def caveats
    if build.with? "app"
      <<~EOS
      WBT.app was installed in:
        #{prefix}

      You may also symlink WBT.app into /Applications or ~/Applications:
        ln -Fs `find $(brew --prefix) -name "WBT.app"` /Applications/WBT.app

      EOS
    end
  end

  test do
    # TODO
  end
end
