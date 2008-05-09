require File.join(File.dirname(__FILE__), "ey_logger")

# These tasks are setup to use with the logger as post commit hooks.
Capistrano::Configuration.instance(:must_exist).load do
  namespace :ey_logger do
    task :upload_log_to_slice, :except => { :no_release => true} do
      logger = Capistrano::EYLogger
      run "mkdir -p #{shared_path}/deploy_logs"
      put File.open(logger.log_file_path).read, "#{shared_path}/deploy_logs/#{logger.remote_log_file_name}"
    end
  end
end

Capistrano::EYLogger.post_process_hook("ey_logger:upload_log_to_slice")