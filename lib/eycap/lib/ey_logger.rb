require 'tmpdir'
# require 'net/ssh'
# require 'net/sftp'
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
    
    def self.setup(configuration, deploy_type, options = {})
      @_configuration = configuration
      @_deploy_type = deploy_type.gsub(/:/, "_")
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
    
    def self.upload
      unless ::Interrupt === $!
        # Should dump the stack trace of an exception if there is one
        error = $!
        unless error.nil?
          @_deploy_log_file << error.message << "\n"
          @_deploy_log_file << error.backtrace.join("\n")
        end
        self.flush
        self.close
        
        upload_file_to_server
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
    
    def self.remote_log_file_name
      @_log_file_name ||= @_configuration[:release_name] + "-" + @_deploy_type + ".log"
    end

    def self.close
      @_deploy_log_file.close unless @_deploy_log_file.nil?
      @_setup = false
    end
    
    def self.upload_file_to_server
      server =  @_configuration.parent.roles[:app].servers.first
      user = @_configuration[:user]
      _password = @_configuration[:password]
      
      Net::SSH.start(server.host, user, _password, :port => server.port) do |ssh|
        puts "Ensuring deploy_logs directory exists"
        ssh.open_channel{|c| c.exec("mkdir -p #{@_configuration[:shared_path]}/deploy_logs")}
        ssh.loop
        puts "Uploading Deploy Log File for: #{@_deploy_type} "
        ssh.sftp.connect do |sftp|
          sftp.put_file log_file_path, "#{@_configuration[:shared_path]}/deploy_logs/#{remote_log_file_name}"
        end
        ssh.loop
        puts "Upload complete"
      end
    end
  end
end