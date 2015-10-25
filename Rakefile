require 'colorize'
require 'open3'

class Shell
  attr_reader :print_types
  attr_writer :print_types

  def initialize(opts)
    @print_types = opts.fetch(:print_types, [])
  end

  def log_type?(type)
    print_types.include? type
  end

  def log(type, msg)
    puts msg if log_type? type
  end

  def ok
    log(:info, "   OK".colorize(:green))
  end

  def group(name=nil, type=:group)
    log type, "-> #{name}" if name
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

  def run(cmd, opt={})
    log :commands, " ~> #{cmd.colorize(:green)}"
    stream = opt.fetch(:stream, true)
    if stream && log_type?(:stdout) && log_type?(:stderr)
      [system(cmd), nil, nil]
    else
      _, stdout, stderr, wait = Open3::popen3 cmd
      out = stdout.read
      err = stderr.read
      stdout.close
      stderr.close
      log :stdout, out
      log :stderr, err

      if stream # to be consistent
        out = nil
        err = nil
      end
      [wait.value, out, err]
    end
  end

  def run!(cmd, opt={})
    status, stdout, stderr = run(cmd, opt)
    fail_if_error(cmd, status, stdout, stderr)
  end

  def read(file)
    log :commands, " ~> read file: #{file.colorize(:gree)}"
    contents = File.read(file)
    log :io, " # Contents\n#{contents}"
    contents
  end

  def write(file, contents)
    log :commands, " ~> write file: #{file.colorize(:gree)}"
    File.write(file, contents)
    log :io, " # Contents\n#{contents}"
    contents
  end

  def xcodebuild(cmd)
    run!("xcodebuild #{cmd}", stream: true)
  end

  private
  def fail_if_error(cmd, status, stdout, stderr)
    unless status
      log :errors, stdout unless print_types.include? :stdout
      log :errors, stderr unless print_types.include? :stderr
      log :errors, ""
      log :errors, "Failed: #{cmd.colorize(:red)}"
      exit 1
    end
    stdout
  end
end

class Dependency
  attr_reader :git_repo, :branch, :name, :path

  def initialize(shell, name, path, git_repo, branch)
    @shell = shell
    @name = name
    @path = File.absolute_path(path)
    @git_repo = git_repo
    @branch = branch
  end

  def change(git_repo, branch)
    @git_repo = git_repo
    @branch = branch
    @shell.run("mkdir -p #{@path.inspect}")
    @shell.cd(@path, "Updating #{@name.colorize(:green)} to #{@git_repo.colorize(:green)} #{@branch.colorize(:blue)}") do
      @shell.run("rm -rf #{@name.inspect}")
      @shell.run!("git clone #{@git_repo.inspect} #{@name.inspect}")
      @shell.cd(@name) do
        @shell.run!("git fetch")
        @shell.run!("git checkout #{@branch.inspect}")
      end
    end
  end

  def vendor_path
    File.join(@path, @name)
  end
end

def with_vendored_cartfile(shell, dependencies)
  contents = []
  dependencies.each do |dependency|
    if File.exists? dependency.vendor_path
      shell.log(:debug, "Using".colorize(:green) + " vendored #{dependency.name}: #{dependency.vendor_path}")
      contents << "git \"file://#{dependency.vendor_path}\" \"#{dependency.branch}\""
    else
      shell.log(:debug, "NOT".colorize(:red) + " using vendored #{dependency.name}: #{dependency.vendor_path}")
      contents << "github \"#{dependency.git_repo}\" \"#{dependency.branch}\""
    end
  end

  backup = shell.read('Cartfile')
  shell.write('Cartfile', contents.join("\n"))
  begin
    yield
  ensure
    shell.write('Cartfile', backup)
  end
end

def with_carthage(shell, dependencies)
  with_vendored_cartfile(shell, dependencies) do
    shell.run("rm -f Cartfile.resolved")
    shell.run("rm -rf Carthage")
    shell.run!("carthage bootstrap", stream: true)
    yield
  end
end

def with_cocoapods(shell)
  shell.run("rm -r Podfile.lock")
  shell.run("rm -rf Pods")
  shell.run!("pod install")
  yield
end

default_print_types = [:group, :errors, :info]
shell = Shell.new(print_types: default_print_types)
nimble = Dependency.new(shell, 'Nimble', './Vendor', 'https://github.com/Quick/Nimble.git', 'master')
quick = Dependency.new(shell, 'Quick', './Vendor', 'https://github.com/Quick/Quick.git', 'master')

task :print_versions do
  shell.group("Xcode Information".colorize(:green)) do
    system("xcodebuild -showsdks")
    system("xcodebuild -version")
  end
end

desc "Makes future rake tasks print verbosely (ranges from 1-2)"
task :verbose, [:level] do |t, args|
  args.with_defaults(level: '1')
  level = args.level.to_i

  shell.print_types = default_print_types
  shell.print_types += [:commands, :stdout, :stderr, :chdirs] if level > 0
  shell.print_types += [:io, :debug] if level > 1
end

task vendor: %w[vendor:nimble vendor:quick]
namespace :vendor do
  desc "Downloads & replaces Nimble in Vendor/Nimble for use by tests. Can optionally specify a git repo and branch to use."
  task :nimble, [:git_repo, :branch] => [:print_versions] do |t, args|
    args.with_defaults(git_repo: 'https://github.com/Quick/Nimble.git', branch: 'master')
    nimble.change(args.git_repo, args.branch)
  end

  desc "Downloads & replaces Quick in Vendor/Quick for use by tests. Can optionally specify a git repo and branch to use."
  task :quick, [:git_repo, :branch] => [:print_versions] do |t, args|
    args.with_defaults(git_repo: 'https://github.com/Quick/Quick.git', branch: 'master')
    quick.change(args.git_repo, args.branch)
  end
end

task ios: %w[ios:cocoapods ios:carthage]
namespace :ios do
  task carthage: %w[ios:carthage:quick ios:carthage:nimble]
  namespace :carthage do
    desc "Runs tests for carthage in ios with App Bundle, Unit Test Bundle, UI Test Bundle for Quick"
    task :quick => [:print_versions] do
      shell.cd('iOS-Carthage', "Testing iOS-Carthage (Quick)") do
        with_carthage(shell, [nimble, quick]) do
          shell.xcodebuild("-scheme iOS-Carthage-Quick -sdk iphonesimulator clean test")
          shell.ok
        end
      end
    end

    desc "Runs tests for carthage in ios with App Bundle, Unit Test Bundle, UI Test Bundle for Nimble"
    task :nimble => [:print_versions] do
      shell.cd('iOS-Carthage', "Testing iOS-Carthage (Nimble)") do
        with_carthage(shell, [nimble, quick]) do
          shell.xcodebuild("-scheme iOS-Carthage-Nimble -sdk iphonesimulator clean test")
          shell.ok
        end
      end
    end
  end

  task cocoapods: %w[ios:cocoapods:quick ios:cocoapods:nimble]
  namespace :cocoapods do
    desc "Runs tests for cocoapods in ios with App Bundle, Unit Test Bundle, UI Test Bundle for Quick"
    task :quick => [:print_versions] do
      shell.cd('iOS-Cocoapods', "Testing iOS-Cocoapods (Quick)") do
        with_cocoapods(shell) do
          shell.xcodebuild("-scheme iOS-Cocoapods-Quick -workspace iOS-Cocoapods.xcworkspace -sdk iphonesimulator clean test")
          shell.ok
        end
      end
    end

    desc "Runs tests for cocoapods in ios with App Bundle, Unit Test Bundle, UI Test Bundle for Nimble"
    task :nimble => [:print_versions] do
      shell.cd('iOS-Cocoapods', "Testing iOS-Cocoapods (Nimble)") do
        with_cocoapods(shell) do
          shell.xcodebuild("-scheme iOS-Cocoapods-Nimble -workspace iOS-Cocoapods.xcworkspace -sdk iphonesimulator clean test")
          shell.ok
        end
      end
    end
  end
end

task osx: %w[osx:carthage osx:cocoapods]
namespace :osx do
  task carthage: %w[osx:carthage:quick osx:carthage:nimble]
  namespace :carthage do
    desc "Runs tests for carthage in osx with App Bundle, Unit Test Bundle, UI Test Bundle for Quick"
    task :quick => [:print_versions] do
      shell.cd('OSX-Carthage', "Testing OSX-Carthage (Quick)") do
        with_carthage(shell, [nimble, quick]) do
          shell.xcodebuild("-scheme OSX-Carthage-Quick clean test")
          shell.ok
        end
      end
    end

    desc "Runs tests for carthage in osx with App Bundle, Unit Test Bundle, UI Test Bundle for Nimble"
    task :nimble => [:print_versions] do
      shell.cd('OSX-Carthage', "Testing OSX-Carthage (Nimble)") do
        with_carthage(shell, [nimble, quick]) do
          shell.xcodebuild("-scheme OSX-Carthage-Nimble clean test")
          shell.ok
        end
      end
    end
  end

  task cocoapods: %w[osx:cocoapods:quick osx:cocoapods:nimble]
  namespace :cocoapods do
    desc "Runs tests for cocoapods in osx with App Bundle, Unit Test Bundle, UI Test Bundle for Quick"
    task :quick => [:print_versions] do
      shell.cd('OSX-Cocoapods', "Testing OSX-Cocoapods (Quick)") do
        with_cocoapods(shell) do
          shell.xcodebuild("-scheme OSX-Cocoapods-Quick -workspace OSX-Cocoapods.xcworkspace clean test")
          shell.ok
        end
      end
    end

    desc "Runs tests for cocoapods in osx with App Bundle, Unit Test Bundle, UI Test Bundle for Nimble"
    task :nimble => [:print_versions] do
      shell.cd('OSX-Cocoapods', "Testing OSX-Cocoapods (Nimble)") do
        with_cocoapods(shell) do
          shell.xcodebuild("-scheme OSX-Cocoapods-Nimble -workspace OSX-Cocoapods.xcworkspace clean test")
          shell.ok
        end
      end
    end
  end
end

desc "Runs all Quick related tests"
task quick: %w[ios:carthage:quick ios:cocoapods:quick osx:carthage:quick osx:cocoapods:quick]

desc "Runs all Nimble related tests"
task nimble: %w[ios:carthage:nimble ios:cocoapods:nimble osx:carthage:nimble osx:cocoapods:nimble]

desc "Removes all Xcode derrived data"
task :clean do
  shell.group('Removing Derived Data...') do
    shell.run("rm -rf ~/Library/Developer/Xcode/DerivedData")
  end
end

task default: %w[ios osx]
