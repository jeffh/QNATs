require 'colorize'
require 'open3'

class Shell
  attr_reader :print_types

  def initialize(opts)
    @print_types = opts.fetch(:print_types, [])
  end

  def log(type, msg)
    puts msg if print_types.include? type
  end

  def cd(dir)
    Dir.chdir(dir) do
      log :chdirs, "-> in #{dir.colorize(:blue)}"
      yield
    end
  end

  def run(cmd)
    log :commands, "-> #{cmd.colorize(:green)}"
    _, stdout, stderr, wait = Open3::popen3 cmd
    out = stdout.read
    err = stderr.read
    stdout.close
    stderr.close
    log :stdout, out
    log :stderr, err
    [wait.value, out, err]
  end

  def run!(cmd)
    status, stdout, stderr = run(cmd)
    fail_if_error(status, stdout, stderr)
  end

  private
  def fail_if_error(status, stdout, stderr)
    unless status == 0
      log :errors, stdout unless print_types.include? :stdout
      log :errors, stderr unless print_types.include? :stderr
      log :errors, ""
      log :errors, "Failed: #{cmd.colorize(:red)}"
      exit 1
    end
    stdout
  end
end

shell = Shell.new(print_types: [:commands, :chdirs, :stdout, :stderr, :errors])

task ios: %w[ios:cocoapods ios:carthage]
namespace :ios do
  desc "Runs tests for carthage in ios with App Bundle, Unit Test Bundle, UI Test Bundle"
  task :carthage do
    shell.cd('iOS-Carthage') do
      shell.run!("carthage bootstrap")
      shell.run!("xcodebuild -scheme iOS-Carthage -sdk iphonesimulator")
    end
  end

  desc "Runs tests for cocoapods in ios with App Bundle, Unit Test Bundle, UI Test Bundle"
  task :cocoapods do
    shell.cd('iOS-Cocoapods') do
      shell.run!("pod install")
      shell.run!("xcodebuild -scheme iOS-Cocoapods -workspace iOS-Cocoapods.xcworkspace -sdk iphonesimulator")
    end
  end
end

namespace :osx do
  task :carthage do
  end
end

task default: %w[ios]
