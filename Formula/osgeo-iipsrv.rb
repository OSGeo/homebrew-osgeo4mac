class OsgeoIipsrv < Formula
  desc "Publish spatial data and interactive mapping apps to the web"
  homepage "https://github.com/ruven/iipsrv"
  url "https://github.com/ruven/iipsrv/archive/f68b225013c54dd08badcd55d0819d29eb4fc5f8.tar.gz"
  sha256 "9d9e90cdc1f4588f1cb14b004c17a07ffa3ad88cd2c3e69582b660483dc5114b"
  version "1.1-dev"

  revision 1

  head "https://github.com/ruven/iipsrv.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "4e6c8c55f45543b26eaa7b031c87a4e00b3cfcbf037aa33c6e62fbef2cf22b6d" => :mojave
    sha256 "4e6c8c55f45543b26eaa7b031c87a4e00b3cfcbf037aa33c6e62fbef2cf22b6d" => :high_sierra
    sha256 "8ce2d0857dcf778a32aef8298b42e2a94d845526c87158fa3c88b24e58612ff3" => :sierra
  end

  option "with-lighttpd", "Install lighttpd and iipsrv configuration file"
  option "with-nginx", "Install nginx and iipsrv configuration file"
  option "without-tests", "Do not run test suite"

  depends_on "autoconf"
  depends_on "automake"
  depends_on "libtool"

  depends_on "pkg-config"

  depends_on "fcgi"
  depends_on "jpeg"
  depends_on "libtiff"
  depends_on "little-cms2"
  depends_on "libmemcached"
  # NOTE: PNG support is currently turned off in configure.in
  depends_on "spawn-fcgi"
  depends_on "lighttpd" => :optional
  depends_on "nginx" => :optional
  depends_on "vips" # for creating Tiled Pyramidal TIFFs
  depends_on "imagemagick" # for creating Tiled Pyramidal TIFFs

  resource "iipmooviewer" do
    url "https://github.com/ruven/iipmooviewer/archive/cbcbe75b1af7d2fcf75c62d8fc650060c8081e13.tar.gz"
    sha256 "0c84fd68b9d295c37d3afd9b659442c0d5ba67ebe3f9c3fe10160d6aca5d9126"
    version "2.0-dev"
  end

  resource "palaisuulouvre" do
    url "http://merovingio.c2rmf.cnrs.fr/iipimage/PalaisDuLouvre.tif"
    sha256 "e76b75c0b16609aa85e02c13b1ccd4c85ff4b452811e7878442422ce8b23ce6b"
  end

  def install
    system "./autogen.sh"
    system "./configure",
      "--disable-dependency-tracking"

    system "make"
    system "make", "check" if build.with? "tests"
    (prefix/"fcgi-bin").install "src/iipsrv.fcgi"
    man1.install "man/iipsrv.8"

    # Out-of-htdocs directory for images
    iipimage = var/"iipimage"
    iipimage.install resource("palaisuulouvre") # sample image

    # Copy of iipmooviewer
    resource("iipmooviewer").stage do
      inreplace "index.html", "/path/to/image.tif", "#{iipimage}/PalaisDuLouvre.tif"
      (prefix/"iipmooviewer").install Dir["*"]
    end

    # Set up log
    # touch iipsrv_log

    # fix for: No such file or directory @ rb_sysopen - /usr/local/var/log/iipsrv.log
    config = <<~EOS
      # iipsrv_log
    EOS
    (var/"log/iipsrv.log").write config

    # Spawn-fcgi utility
    (bin/"iipsrv-spawn").write(spawn_script)
  end

  def spawn_script; <<~EOS
    #!/bin/bash

    export LOGFILE=#{iipsrv_log}
    export VERBOSITY=5
    export MAX_IMAGE_CACHE_SIZE=10
    export FILENAME_PATTERN=_pyr_
    export JPEG_QUALITY=50
    export MAX_CVT=3000
    exec 2>&1
    exec #{Formula["spawn-fcgi"].opt_bin}/spawn-fcgi -n -s #{iipsrv_sock} -- #{opt_prefix}/fcgi-bin/iipsrv.fcgi &
    EOS
  end

  plist_options :manual => "iipsrv-spawn"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <false/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{Formula["spawn-fcgi"].opt_bin}/spawn-fcgi</string>
        <string>-n</string>
        <string>-s</string>
        <string>#{iipsrv_sock}</string>
        <string>--</string>
        <string>#{opt_prefix}/fcgi-bin/iipsrv.fcgi</string>
      </array>
      <key>EnvironmentVariables</key>
      <dict>
        <key>LOGFILE</key>
        <string>#{iipsrv_log}</string>
        <key>VERBOSITY</key>
        <string>5</string>
        <key>MAX_IMAGE_CACHE_SIZE</key>
        <string>10</string>
        <key>FILENAME_PATTERN</key>
        <string>_pyr_</string>
        <key>JPEG_QUALITY</key>
        <string>50</string>
        <key>MAX_CVT</key>
        <string>3000</string>
      </dict>
      <key>UserName</key>
      <string>#{`whoami`.chomp}</string>
    </dict>
    </plist>
    EOS
  end

  def iipsrv_log
    "#{var}/log/iipsrv.log"
  end

  def iipsrv_sock
    "#{var}/run/iipsrv.sock"
  end

  def post_install
    conf_dir = prefix/"config"
    opts = Tab.for_formula(self).used_options

    conf_s = conf_dir/"lighttpd_iipsrv_spawn.conf.sample"
    rm_f conf_s
    conf_s.write <<~EOS
      server.modules += ( "mod_fastcgi" )
      fastcgi.server = ( "/fcgi-bin/iipsrv.fcgi" =>
        (( "socket" => "#{iipsrv_sock}",
           "check-local" => "disable"
        ))
      )
    EOS

    conf_s = conf_dir/"lighttpd_iipsrv.conf.sample"
    rm_f conf_s
    conf_s.write <<~EOS
      server.modules += ( "mod_fastcgi" )
      fastcgi.server = ( "/fcgi-bin/iipsrv.fcgi" =>
        (( "socket" => "#{iipsrv_sock}",
           "check-local" => "disable",
           "min-procs" => 1,
           "max-procs" => 2,
           "bin-path" => "#{opt_prefix}/fcgi-bin/iipsrv.fcgi",
           "bin-environment" => (
              "LOGFILE" => "#{iipsrv_log}",
              "VERBOSITY" => "5",
              "MAX_IMAGE_CACHE_SIZE" => "10",
              "FILENAME_PATTERN" => "_pyr_",
              "JPEG_QUALITY" => "50",
              "MAX_CVT" => "3000"
            )
        ))
      )
    EOS

    if opts.include? "with-lighttpd"
      conf = etc/"lighttpd/conf.d/iipsrv.conf"
      rm conf if File.exist? conf
      cp conf_s, conf

      # Make sure iipsrv.conf will be loaded
      inc_conf = 'include "conf.d/iipsrv.conf"'
      mod_conf = etc/"lighttpd/modules.conf"
      unless File.readlines(mod_conf).grep(/#{Regexp.escape inc_conf}/).any?
        mod_conf.open("a") { |f| f.write("\n" + inc_conf) }
      end
    end

    conf_s = conf_dir/"apache_iipsrv.conf.sample"
    rm_f conf_s
    conf_s.write <<~EOS
      # Set the options on that directory
      <Directory "#{opt_prefix}/fcgi-bin">
        AllowOverride None
        Options None
        Order allow,deny
        Allow from all
      </Directory>

      # Set the handler
      AddHandler fastcgi-script fcgi

      # Initialise the FCGI server - set some default values
      FastCgiServer #{opt_prefix}/fcgi-bin/iipsrv.fcgi \
      -initial-env LOGFILE=#{iipsrv_log} \
      -initial-env VERBOSITY=2 \
      -initial-env JPEG_QUALITY=50 \
      -initial-env MAX_IMAGE_CACHE_SIZE=10 \
      -initial-env MAX_CVT=3000 \
      -processes 2
    EOS

    conf_s = conf_dir/"nginx_iipsrv.conf.sample"
    rm_f conf_s
    conf_s.write <<~EOS
      location /fcgi-bin/iipsrv.fcgi {
        include fastcgi_params;
        fastcgi_pass unix:#{iipsrv_sock};
      }
    EOS
    if opts.include? "with-nginx"
      conf = etc/"nginx/iipsrv.conf"
      rm conf if File.exist? conf
      cp conf_s, conf
    end
  end

  def caveats; <<~EOS
    When IIPImage Server is launched from its plist or iipsrv-spawn script, the
    FastCGI process with be available at:
      #{iipsrv_sock}

    Tiled TIFF images can be stored in #{var}/iipimage (outside the www tree).
    There is a sample already installed there: PalaisDuLouvre.tif.

    There are configuration scripts in #{opt_prefix}/config for the following
    web servers (copy the whatever.sample to iipsrv.conf accordingly):

    * Lighttpd - can spawn the FastCGI process (no external spawning needed), or
                 connect externally to the spawned FastCGI process

      config:   #{etc}/lighttpd/conf.d/iipsrv.conf
      include:  include "conf.d/iipsrv.conf"
           in:  #{etc}/lighttpd/modules.conf
      www root: #{var}/www/htdocs

    * Nginx - connects to the externally spawned FastCGI process

      config:   #{etc}/nginx/iipsrv.conf
      include:  include iipsrv.conf;
           in:  #{etc}/nginx/nginx.conf <-- (or other .conf's) 'server' block
      www root: #{var}/www

    * Apache - can spawn the FastCGI process (no external spawning needed), or
               connect externally to the spawned FastCGI process

               homebrew/apache/mod_fastcgi REQUIRED

      config:   /etc/apache2/other/iipsrv.conf
      www root: /Library/WebServer/Documents

    Upon successful server configuration test at:

      http://localhost[:port]/fcgi-bin/iipsrv.fcgi

    An install of 'iipmooviewer' is in #{opt_prefix}. Copy the 'iipmooviewer'
    directory to your server's www root. Test viewer, with sample image, at:

      http://localhost[:port]/iipmooviewer

  EOS
  end

  test do
  end
end
