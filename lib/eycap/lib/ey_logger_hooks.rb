Capistrano::EYLogger.post_process_hook(:any, :start_message => "Uploading log file to server", 
                                             :finish_message => Proc.new{|l,conf| puts "Uploaded #{l.remote_log_file_name}"}) do |ssh, config,logger|
  puts "Ensuring deploy_logs directory exists"
  ssh.open_channel{|c| c.exec("mkdir -p #{config[:shared_path]}/deploy_logs")}
  ssh.loop
  puts "Uploading Deploy Log File for: #{logger.deploy_type} "
  ssh.sftp.connect do |sftp|
    sftp.put_file logger.log_file_path, "#{config[:shared_path]}/deploy_logs/#{logger.remote_log_file_name}"
  end
  ssh.loop
end