require 'tmpdir'
module Capistrano
  
  class Logger  
    
    def ey_log(level, message, line_prefix = nil)
      EYLogger.log_it(level, message, line_prefix) if EYLogger.setup?
      no_ey_logging(level, message, line_prefix)
    end
    
    alias_method :no_ey_logging, :log unless method_defined?(:no_ey_logging)
    alias_method :log, :ey_log
    
    def close
      device.close if @needs_close
      EYLogger.close if EYLogger.setup?
    end
  end
  
  class EYLogger
    
    def self.setup(configuration, options = {})
      @_configuration = configuration
      @_log_path = options[:deploy_log_path] || Dir.tmpdir
      FileUtils.mkdir_p(@_log_path)
      @_setup = true
    end
    
    def self.log_it(level, message, line_prefix=nil)
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

    def self.setup?
      @_setup
    end   
    
    def self.flush
      @_deploy_log_file.flush unless @_deploy_log_file.nil?
    end
    
    def self.log_file_path
      @_log_file_path
    end

    def self.close
      @_deploy_log_file.close unless @_deploy_log_file.nil?
      @_setup = false
    end
  end
end