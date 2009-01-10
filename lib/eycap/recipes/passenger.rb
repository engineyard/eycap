Capistrano::Configuration.instance(:must_exist).load do
  namespace :passenger do
    desc <<-DESC
    Restart the passenger module to reload the application after deploying.
    DESC
    task :restart, :roles => :app, :except => {:no_release => true} do
      sudo "touch #{current_path}/tmp/restart.txt"
    end
  end
end