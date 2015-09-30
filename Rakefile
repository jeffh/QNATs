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

  def group(name=nil)
    log :group, "-> #{name}" if name
    yield
  end

  def cd(dir, group_name=nil)
    group(group_name) do
      Dir.chdir(dir) do
        log :chdirs, " ~> cd #{dir.colorize(:blue)}"
        yield
      end
    end
  end

  def run(cmd)
    log :commands, " ~> #{cmd.colorize(:green)}"
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
    fail_if_error(cmd, status, stdout, stderr)
  end

  private
  def fail_if_error(cmd, status, stdout, stderr)
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

shell = Shell.new(print_types: [:group, :errors])

desc "Makes future rake tasks print verbosely"
task :verbose do
  shell = Shell.new(print_types: shell.print_types + [:commands, :stdout, :stderr, :chdirs])
end

task ios: %w[ios:cocoapods ios:carthage]
namespace :ios do
  desc "Runs tests for carthage in ios with App Bundle, Unit Test Bundle, UI Test Bundle"
  task :carthage do
    shell.cd('iOS-Carthage', "Testing iOS-Carthage") do
      shell.run("rm -f Cartfile.resolved")
      shell.run("rm -rf Carthage")
      shell.run!("carthage bootstrap")
      shell.run!("xcodebuild -scheme iOS-Carthage -sdk iphonesimulator clean test")
    end
  end

  desc "Runs tests for cocoapods in ios with App Bundle, Unit Test Bundle, UI Test Bundle"
  task :cocoapods do
    shell.cd('iOS-Cocoapods', "Testing iOS-Cocoapods") do
      shell.run("rm -r Podfile.lock")
      shell.run("rm -rf Pods")
      shell.run!("pod install")
      shell.run!("xcodebuild -scheme iOS-Cocoapods -workspace iOS-Cocoapods.xcworkspace -sdk iphonesimulator clean test")
    end
  end
end

task osx: %w[osx:carthage osx:cocoapods]
namespace :osx do
  desc "Runs tests for carthage in osx with App Bundle, Unit Test Bundle, UI Test Bundle"
  task :carthage do
    shell.cd('OSX-Carthage', "Testing OSX-Carthage") do
      shell.run("rm -f Cartfile.resolved")
      shell.run("rm -rf Carthage")
      shell.run!("carthage bootstrap")
      shell.run!("xcodebuild -scheme OSX-Carthage clean test")
    end
  end

  desc "Runs tests for cocoapods in osx with App BUndle, Unit Test Bundle, UI Test Bundle"
  task :cocoapods do
    shell.cd('OSX-Cocoapods', "Testing OSX-Cocoapods") do
      shell.run("rm -r Podfile.lock")
      shell.run("rm -rf Pods")
      shell.run!("pod install")
      shell.run!("xcodebuild -scheme OSX-Cocoapods -workspace OSX-Cocoapods.xcworkspace clean test")
    end
  end
end

task default: %w[ios osx]
