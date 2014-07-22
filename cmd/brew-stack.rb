# Install a formula and dependencies from pre-made bottles or as built bottles.
#
# Useful for creating a portable Homebrew directory for a specific OS version.
# Example: portable domain-specific software stack in custom Homebrew prefix

require "formula"
require "formula_installer"
require "utils"

def usage; <<-EOS
  Usage: brew stack [install-options...] formula [formula-options...]

         Same options as for `brew install`, but only for a single formula.
         Note: --interactive install option is not supported
  EOS
end

def system_out cmd, *args
  # echo command
  puts "#{Tty.blue}==>#{Tty.blue} #{cmd} #{args*' '}#{Tty.reset}" unless ARGV.verbose?
  # sync output to tty
  # stdout_prev, stderr_prev = $stdout.sync, $stderr.sync
  # $stdout.sync, $stderr.sync = true, true
  res = Homebrew.system cmd, *args
  # $stdout.sync, $stderr.sync = stdout_prev, stderr_prev
  res
end

if ARGV.formulae.length != 1 || ARGV.interactive?
  puts usage
  exit 1
end

if ARGV.include? "--help"
  puts usage
  exit 0
end

f = ARGV.formulae[0]
opts = ARGV.options_only

# Check if already installed
if f.installed?
  opoo "#{f} already installed"
  exit 0
end

# Necessary to get dependencies to build as bottle if they install from source
ENV["HOMEBREW_BUILD_BOTTLE"] = "1"

# Install main formula's dependencies first
unless system_out "brew", "install", "#{f}", *(opts + %W[--only-dependencies])
  exit! 1
end

# Unset to ensure bottle for main formula is poured, if pourable
ENV.delete "HOMEBREW_BUILD_BOTTLE"

# Is main formula pourable?
pour_bottle = false
unless ARGV.build_bottle? # --build-bottle defined
  fi = FormulaInstaller.new(f)
  fi.options             = f.build.used_options
  fi.build_bottle        = ARGV.build_bottle?
  fi.build_from_source   = ARGV.build_from_source?
  fi.force_bottle        = ARGV.force_bottle?

  pour_bottle = fi.pour_bottle?
  opts |= %W[--build-bottle] if ARGV.build_from_source? or !pour_bottle
end

# Necessary to raise error if bottle fails to pour
ENV["HOMEBREW_DEVELOPER"] = "1" if pour_bottle

# Pour or install main formula
unless system_out "brew", "install", "#{f}", *opts
  if pour_bottle
    opoo "Bottle may have failed to install"
    ohai "Attempting to build source as bottle"
    opts |= %W[--build-bottle]

    unless system_out "brew", "install", "#{f}", *opts
      odie "Source bottle build failed"
    end
  else
    odie "Source bottle build failed"
  end
end

exit 0
