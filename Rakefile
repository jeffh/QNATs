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
    _, stdout, stderr, wait = Open3::popen3 cmd
    if opt.fetch(:stream, false)
      IO.copy_stream(stdout, STDOUT) if log_type? :stdout
      IO.copy_stream(stderr, STDERR) if log_type? :stderr
    else
      out = stdout.read
      err = stderr.read
      stdout.close
      stderr.close
      log :stdout, out
      log :stderr, err
      [wait.value, out, err]
    end
  end

  def run!(cmd, opt={})
    status, stdout, stderr = run(cmd, opt={})
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
      @shell.run!("git checkout #{@branch.inspect}")
    end
  end

  def vendor_path
    File.join(@path, @name)
  end

  def with_vendored_cartfile
    if File.exists? vendor_path
      @shell.group("#{'Using'.colorize(:green)} vendored #{@name}: #{vendor_path}", :debug) do
        backup = @shell.read('Cartfile')
        @shell.write('Cartfile', "git \"file://#{vendor_path}\" \"#{@branch}\"")
        begin
          yield
        ensure
          @shell.write('Cartfile', backup)
        end
      end
    else
      @shell.group("#{'NOT'.colorize(:red)} using vendored #{@name}", :debug) do
        yield
      end
    end
  end
end

default_print_types = [:group, :errors, :info]
shell = Shell.new(print_types: default_print_types)
nimble = Dependency.new(shell, 'Nimble', './Vendor', 'https://github.com/Quick/Nimble.git', 'master')

desc "Makes future rake tasks print verbosely (ranges from 1-2)"
task :verbose, [:level] do |t, args|
  args.with_defaults(level: '1')
  level = args.level.to_i

  shell.print_types = default_print_types
  shell.print_types += [:commands, :stdout, :stderr, :chdirs, :stream, :io, :debug] if level > 0
  shell.print_types += [:io, :debug] if level > 1
end

desc "Updates Nimble dependency"
task :update_nimble, [:git_repo, :branch] do |t, args|
  args.with_defaults(git_repo: 'https://github.com/Quick/Nimble.git', branch: 'master')
  nimble.change(args.git_repo, args.branch)
end

task ios: %w[ios:cocoapods ios:carthage]
namespace :ios do
  desc "Runs tests for carthage in ios with App Bundle, Unit Test Bundle, UI Test Bundle"
  task :carthage do
    shell.cd('iOS-Carthage', "Testing iOS-Carthage") do
      nimble.with_vendored_cartfile do
        shell.run("rm -f Cartfile.resolved")
        shell.run("rm -rf Carthage")
        shell.run!("carthage bootstrap", stream: true)
        shell.run!("xcodebuild -scheme iOS-Carthage -sdk iphonesimulator clean test", stream: true)
        shell.ok
      end
    end
  end

  desc "Runs tests for cocoapods in ios with App Bundle, Unit Test Bundle, UI Test Bundle"
  task :cocoapods do
    shell.cd('iOS-Cocoapods', "Testing iOS-Cocoapods") do
      shell.run("rm -r Podfile.lock")
      shell.run("rm -rf Pods")
      shell.run!("pod install", stream: true)
      shell.run!("xcodebuild -scheme iOS-Cocoapods -workspace iOS-Cocoapods.xcworkspace -sdk iphonesimulator clean test", stream: true)
      shell.ok
    end
  end
end

task osx: %w[osx:carthage osx:cocoapods]
namespace :osx do
  desc "Runs tests for carthage in osx with App Bundle, Unit Test Bundle, UI Test Bundle"
  task :carthage do
    shell.cd('OSX-Carthage', "Testing OSX-Carthage") do
      nimble.with_vendored_cartfile do
        shell.run("rm -f Cartfile.resolved")
        shell.run("rm -rf Carthage")
        shell.run!("carthage bootstrap", stream: true)
        shell.run!("xcodebuild -scheme OSX-Carthage clean test", stream: true)
        shell.ok
      end
    end
  end

  desc "Runs tests for cocoapods in osx with App BUndle, Unit Test Bundle, UI Test Bundle"
  task :cocoapods do
    shell.cd('OSX-Cocoapods', "Testing OSX-Cocoapods") do
      shell.run("rm -r Podfile.lock")
      shell.run("rm -rf Pods")
      shell.run!("pod install", stream: true)
      shell.run!("xcodebuild -scheme OSX-Cocoapods -workspace OSX-Cocoapods.xcworkspace clean test", stream: true)
      shell.ok
    end
  end
end

task default: %w[update_nimble ios osx]
