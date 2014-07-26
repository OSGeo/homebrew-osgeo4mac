require "formula"

class Iipsrv < Formula
  homepage "http://iipimage.sourceforge.net"
  url "https://github.com/ruven/iipsrv.git", :revision => "cfffce90243148a3da4a13776f3764b280acd0ce"
  version "0.9.9-dev"

  option "with-lighttpd", "Install lighttpd and iipsrv configuration file"
  option "with-nginx", "Install nginx and iipsrv configuration file"
  option "with-vips", "Install VIPS for creating Tiled Pyramidal TIFFs"
  option "with-imagemagick", "Install ImageMagick for creating Tiled Pyramidal TIFFs"

  depends_on :autoconf
  depends_on :automake
  depends_on :libtool

  depends_on "fcgi"
  depends_on "jpeg"
  depends_on "libtiff"
  depends_on "little-cms2"
  depends_on "libmemcached"
  # NOTE: PNG support is currently turned off in configure.in
  depends_on "spawn-fcgi"
  depends_on "lighttpd" => :optional
  depends_on "nginx" => :optional
  depends_on "vips" => :optional
  depends_on "imagemagick" => :optional

  resource "iipmooviewer" do
    url "https://github.com/ruven/iipmooviewer.git", :revision => "21b7b92d9c8187e7239ff98d4cc36c3e03d950c4"
    version "2.0-dev"
  end

  resource "palaisuulouvre" do
    url "http://merovingio.c2rmf.cnrs.fr/iipimage/PalaisDuLouvre.tif"
    sha1 "ef539b5f10745cbd1ff18d47bb8c87c3e9fb7c5a"
  end

  def install
    system "./autogen.sh"
    system "./configure",
      "--disable-dependency-tracking"

    system "make"
    (prefix/"fcgi-bin").install "src/iipsrv.fcgi"
    man8.install "man/iipsrv.8"

    # Out-of-htdocs directory for images
    iipimage = var/"iipimage"
    iipimage.install resource("palaisuulouvre") # sample image

    # Copy of iipmooviewer
    resource("iipmooviewer").stage do
      inreplace "index.html", "/path/to/image.tif", "#{iipimage}/PalaisDuLouvre.tif"
      (prefix/"iipmooviewer").install Dir["*"]
    end

    # Set up log
    touch iipsrv_log

    # Spawn-fcgi utility
    (bin/"iipsrv-spawn").write(spawn_script)
  end

  def spawn_script; <<-EOS.undent
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

  def plist; <<-EOS.undent
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
    conf_s.write <<-EOS.undent
      server.modules += ( "mod_fastcgi" )
      fastcgi.server = ( "/fcgi-bin/iipsrv.fcgi" =>
        (( "socket" => "#{iipsrv_sock}",
           "check-local" => "disable"
        ))
      )
    EOS

    conf_s = conf_dir/"lighttpd_iipsrv.conf.sample"
    rm_f conf_s
    conf_s.write <<-EOS.undent
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
    conf_s.write <<-EOS.undent
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
    conf_s.write <<-EOS.undent
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

  def caveats; <<-EOS.undent
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
    system "#{prefix}/fcgi-bin/iipsrv.fcgi"
  end
end
