require 'tmpdir'
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
      # unless ::Interrupt === $!
        # Should dump the stack trace of an exception if there is one
        error = $!
        unless error.nil?
          @_deploy_log_file << error.message << "\n"
          @_deploy_log_file << error.backtrace.join("\n")
          @_success = false
        end
        self.close
        
        server =    @_configuration.parent.roles[:app].servers.first
        user =      @_configuration[:user]
        _password = @_configuration[:password]
        
        # Net::SSH.start(server.host, user, _password, :port => server.port) do |ssh| # Works with Net::SSH 1.x
        Net::SSH.start(server.host, user, :password => _password, :port => server.port) do |ssh| # Works with Net::SSH 2.X
          hooks = [:any]
          hooks << self.successful? ? :success : :failure
          puts "Executing Post Processing Hooks"
          hooks.each do |h|
            @_post_process_hooks[h].each do |opts, pph|
              render_message opts[:start_message]
              pph.call(ssh, @_configuration, self)
              render_message opts[:finish_message]
            end
          end
          puts "Finished Post Processing Hooks"
        # end
      end
    end
    
    # Adds a post processing hook.  
    # Takes a key to control when the hook is executed.
    # :any - always executed
    # :success - only execute on success
    # :failure - only execute on failure
    #
    # Takes an options hash.  Valid options are
    #   <tt>:start_message</tt> - A message rendered to the user when beginning the hook.  Can be String or proc
    #   <tt>:finish_message</tt> - A message rendered to the user when finishing the hook. Can be String or proc
    #  Message procs are yielded the logger instance and the configuraiton instance
    #
    #  === Example
    #  Capistrano::EYLogger.post_process_hook(:finish_message => Proc.new{|log,config| puts "Deploy Type #{log.deploy_type}"}) do |ssh, config, logger|
    #    # stuff
    #  end
    #
    # Since this occurs outside the normal capistrano execution tasks, and the connection are not directly accessible.
    # instead, an active ssh connection is passed to the block, along with the capistrano configuration.
    # cap variables are accessible
    #
    #  ==== Example
    #
    #  EYLogger.post_process_hook(:success) do |ssh, config, logger|
    #    ssh.sftp.connect do |sftp|
    #     sftp.put_file logger.log_file_path, "#{config[:shared_path]}/deploy_logs/#{logger.remote_log_file_name}"
    #    end
    #  end
    def self.post_process_hook(key = :any, opts = {}, &blk)
      raise "You must supply a block" unless block_given?
      @_post_process_hooks ||= Hash.new{|h,k| h[k] = []}
      @_post_process_hooks[key] << [opts, blk]
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
    
    private 
    def self.render_message(msg)
      return if msg.nil?
      case msg
      when String
        puts msg
      when Proc
        msg.call(self, @_configuration)
      end
    end
  end
end