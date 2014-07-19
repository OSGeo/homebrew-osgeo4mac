# Install a formula and dependencies from pre-made bottles or as built bottles.
#
# Useful for creating a portable Homebrew directory for a specific OS version.
# Example: portable domain-specific software stack in custom Homebrew prefix

require "formula"
require "formula_installer"
require "pty"
require "utils"

def usage; <<-EOS
  Usage: brew stack [install-options...] formula [formula-options...]

         Same options as for `brew install`, but only for a single formula.
         Note: --interactive install option is not supported
  EOS
end

def oohai title, *sput
  # don't truncate, like ohai
  puts "#{Tty.blue}==>#{Tty.blue} #{title}#{Tty.reset}"
  puts sput unless sput.empty?
end

def exec_out cmd
  oohai cmd
  # IO.popen(cmd).each do |line|
  #   puts line
  # end.close

  begin
    PTY.spawn( cmd ) do |r, w, pid|
      begin
        r.each { |line| print line;}
      rescue Errno::EIO
      end
    end
  rescue PTY::ChildExited => e
    puts "The child process exited!"
  end
end

if ARGV.formulae.length != 1 || ARGV.interactive?
  puts usage
  exit 1
end

if ARGV.include? "--help"
  puts usage
  exit 0
end

# Necessary to get dependencies to build as bottle if they install from source
ENV["HOMEBREW_BUILD_BOTTLE"] = "1"

f = ARGV.formulae[0]
opts = ARGV.options_only

# Install just dependencies
exec_out "brew install #{f} #{(opts + ["--only-dependencies"]).join(" ")}"

# Unset to ensure bottle for main formula is poured, if pourable
ENV.delete "HOMEBREW_BUILD_BOTTLE"

unless ARGV.build_bottle? # --build-bottle defined
  fi = FormulaInstaller.new(f)
  fi.options             = f.build.used_options
  fi.build_bottle        = ARGV.build_bottle?
  fi.build_from_source   = ARGV.build_from_source?
  fi.force_bottle        = ARGV.force_bottle?

  opts |= ["--build-bottle"] if ARGV.build_from_source? or !fi.pour_bottle?
end
exec_out "brew install #{f} #{opts.join(" ")}"

exit 0
