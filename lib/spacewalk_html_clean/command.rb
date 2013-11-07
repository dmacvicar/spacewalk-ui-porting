require 'logger'
require 'clamp'
require 'diffy'

#require File.join(libdir, 'jericho-html-3.3.jar')
require 'jericho-html-3.3.jar'

import 'net.htmlparser.jericho.Source'
import 'net.htmlparser.jericho.OutputDocument'
import 'net.htmlparser.jericho.Attributes'
include Java


module SpacewalkHtmlClean

  # Jericho needs an object implementing the
  # interface
  # http://jericho.htmlparser.net/docs/javadoc/net/htmlparser/jericho/Logger.html
  # we create an adapter for the ruby logger
  class JerichoLoggerAdapter
    def initialize(logger)
      @logger = logger
    end
    def isErrorEnabled() @logger.error? end
    def isDebugEnabled() @logger.debug? end
    def isInfoEnabled() @logger.info? end
    def isWarnEnabled() @logger.warn? end

    def method_missing(name, *args)
      @logger.send(name, *args)
    end
  end

  def self.generate_diff(before, after, path)
    begin
      diff = Diffy::Diff.new(before, after, :include_diff_info => true).to_s.lines.reject {|x| x =~ /^([-+]{3})/}.join
      unless diff.empty?
        puts "--- a/#{path} #{Time.now}"
        puts "+++ b/#{path} #{Time.now}"
        puts diff
      end
    rescue
      STDERR.puts "Failed diff for #{path}"
    end
  end


  class Command < Clamp::Command

    def applicable?(tag)
      raise NotImplementedError
    end

    def self.command_name
      name = self.to_s.split(/::/).last
      name.gsub!(/(.)([A-Z])/,'\1-\2').downcase rescue name.downcase
    end

    def self.top_git_directory
      dir = Dir.pwd
      while dir != '/'
        return File.expand_path(dir) if File.directory?(File.join(dir, '.git'))
        dir = File.dirname(dir)
      end
      raise "Can't find top .git directory"
    end

    def top_git_directory
      unless @top_git_directory
        @top_git_directory = self.class.top_git_directory
      end
      @top_git_directory
    end

    # Implementation of Clamp::Command#execute
    # Delegates to SpacewalkHtmlClean#Command#process_tag
    def execute

      logger = Logger.new("/dev/null")
      logger.level = Logger::WARN
      log_adapter = JerichoLoggerAdapter.new(logger)

      perl_pages = File.join(top_git_directory, 'java/code/**/*.{jsp,jspf}')
      java_pages = File.join(top_git_directory, 'web//**/*.{pxt, pxi}')
      [perl_pages, java_pages].each do |pages|
        Dir.glob(pages).each do |path|
          content = File.read(path)
          on_file_start(content, path)
          source = Source.new(content)
          source.setLogger(log_adapter)
          out = OutputDocument.new(source)

          tags = source.getAllStartTags
          tags.each do |tag|
            if applicable?(tag)
              process_tag(source, out, tag, path)
            end
          end

          on_file_changed(content, out.toString, path)
          on_file_done(path)
        end
      end

      Dir.glob(File.join(top_git_directory, 'java/code/**/*.{java}')).each do |path|
        content = File.read(path)
        on_file_start(content, path)
        on_file_done(path)
      end

      Dir.glob(File.join(top_git_directory, 'web/**/*.{pm}')).each do |path|
        content = File.read(path)
        on_file_start(content, path)
        on_file_done(path)
      end

      on_done
    end

    def process_tag(source, out, tag, path)
      raise NotImplementedError
    end

    def on_file_start(content, path)
    end

    # has to be called
    def on_file_changed(content, out, path)
      SpacewalkHtmlClean.generate_diff(content, out, path)
    end

    def on_file_done(path)
    end

    def on_done
    end

  end

end