require 'tmpdir'
require 'fileutils'
module Capistrano
  
  class Logger  
    
    def ey_log(level, message, line_prefix = nil)
      EYLogger.log(level, message, line_prefix) if EYLogger.setup?
      log_without_ey_logging(level, message, line_prefix)
    end
    
    unless method_defined?(:log_without_ey_logging)
      alias_method :log_without_ey_logging, :log 
      alias_method :log, :ey_log
    end
    
    def close
      device.close if @needs_close
      EYLogger.close if EYLogger.setup?
    end
  end
  
  class EYLogger
    
    # Sets up the EYLogger to beging capturing capistrano's logging.  You should pass the capistrno configuration
    # and the deploy type as a string.  The deploy type is for reporting purposes only but must be included.  
    def self.setup(configuration, deploy_type, options = {})
      @_configuration = configuration
      @_deploy_type = deploy_type.gsub(/:/, "_")
      @_log_path = options[:deploy_log_path] || Dir.tmpdir
      @_log_path << "/" unless @_log_path =~ /\/$/
      FileUtils.mkdir_p(@_log_path)
      @_setup = true
      @_success = true
    end
    
    def self.log(level, message, line_prefix=nil)
      return nil unless setup?
      @release_name = @_configuration[:release_name] if @release_name.nil?
      @_log_file_path = @_log_path + @release_name + ".log" unless @_log_file_path
      @_deploy_log_file = File.open(@_log_file_path, "w") if @_deploy_log_file.nil?
       
      indent = "%*s" % [Logger::MAX_LEVEL, "*" * (Logger::MAX_LEVEL - level)]
      message.each do |line|
        if line_prefix
          @_deploy_log_file << "#{indent} [#{line_prefix}] #{line.strip}\n"
        else
          @_deploy_log_file << "#{indent} #{line.strip}\n"
        end
      end
    end
    
    def self.post_process      
      unless ::Interrupt === $!
        puts "\n\nPlease wait while the log file is processed\n"
        # Should dump the stack trace of an exception if there is one
        error = $!
        unless error.nil?
          @_deploy_log_file << error.message << "\n"
          @_deploy_log_file << error.backtrace.join("\n")
          @_success = false
        end
        self.close

        hooks = [:any]
        hooks << self.successful? ? :success : :failure
        puts "Executing Post Processing Hooks"
        hooks.each do |h|
          @_post_process_hooks[h].each do |key|
            @_configuration.parent.find_and_execute_task(key)
          end
        end
        puts "Finished Post Processing Hooks"
      end
    end
    
    # Adds a post processing hook.  
    #
    # Provide a task name to execute.  These tasks are executed after capistrano has actually run its course. 
    #
    # Takes a key to control when the hook is executed.'
    # :any - always executed
    # :success - only execute on success
    # :failure - only execute on failure
    #
    # ==== Example
    #  Capistrano::EYLogger.post_process_hook( "ey_logger:upload_log_to_slice", :any) 
    #
    def self.post_process_hook(task, key = :any)
      @_post_process_hooks ||= Hash.new{|h,k| h[k] = []}
      @_post_process_hooks[key] << task
    end

    def self.setup?
      !!@_setup
    end   
    
    def self.deploy_type
      @_deploy_type
    end
    
    def self.successful?
      !!@_success
    end
    
    def self.failure?
      !@_success
    end
    
    def self.log_file_path
      @_log_file_path
    end
    
    def self.remote_log_file_name
      @_log_file_name ||= "#{@_configuration[:release_name]}-#{@_deploy_type}-#{self.successful? ? "SUCCESS" : "FAILURE"}.log"
    end
    
    def self.close
      @_deploy_log_file.flush unless @_deploy_log_file.nil?
      @_deploy_log_file.close unless @_deploy_log_file.nil?
      @_setup = false
    end
    
  end
end