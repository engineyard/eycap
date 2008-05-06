Capistrano::EYLogger.post_process_hook(:any, :start_message => "Uploading log file to server", 
                                             :finish_message => Proc.new{|l,conf| puts "Uploaded #{l.remote_log_file_name}"}) do |ssh, config,logger|
  puts "Ensuring deploy_logs directory exists"
  ssh.open_channel{|c| c.exec("mkdir -p #{config[:shared_path]}/deploy_logs")}
  ssh.loop
  puts "Uploading Deploy Log File for: #{logger.deploy_type} "
  ssh.sftp.connect do |sftp|
    remote_file_name = "#{config[:shared_path]}/deploy_logs/#{logger.remote_log_file_name}"
    if sftp.respond_to?(:put_file)
      # Net::SFTP 1.X
      sftp.put_file logger.log_file_path, remote_file_name
    else 
      # Net::SFTP 2.X
      sftp.upload! logger.log_file_path, remote_file_name
    end
  end
  ssh.loop
end