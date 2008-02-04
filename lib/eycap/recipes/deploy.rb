Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :deploy do
    
    desc "Link the database.yml and mongrel_cluster.yml files into the current release path."
    task :symlink_configs, :roles => :app, :except => {:no_release => true} do
      run <<-CMD
        cd #{release_path} &&
        ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
        ln -nfs #{shared_path}/config/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml
      CMD
    end
  
    desc "Display the maintenance.html page while deploying with migrations. Then it restarts and enables the site again."
    task :long do
      transaction do
        update_code
        web.disable
        symlink
        migrate
      end
  
      restart
      web.enable
    end

    desc "Restart the Mongrel processes on the app slices."
    task :restart, :roles => :app do
      mongrel.restart
    end

    desc "Start the Mongrel processes on the app slices."
    task :spinner, :roles => :app do
      mongrel.start
    end

    desc "Start the Mongrel processes on the app slices."
    task :start, :roles => :app do
      mongrel.start
    end    
    
    desc "Stop the Mongrel processes on the app slices."
    task :stop, :roles => :app do
      mongrel.stop
    end
    
  end

end