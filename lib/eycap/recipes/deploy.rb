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
    
    namespace :web do
      desc <<-DESC
        Present a maintenance page to visitors. Disables your application's web \
        interface by writing a "maintenance.html" file to each web server. The \
        servers must be configured to detect the presence of this file, and if \
        it is present, always display it instead of performing the request.

        By default, the maintenance page will just say the site is down for \
        "maintenance", and will be back "shortly", but you can customize the \
        page by specifying the REASON and UNTIL environment variables:

          $ cap deploy:web:disable \\
                REASON="hardware upgrade" \\
                UNTIL="12pm Central Time"

        Further customization copy your html file to shared_path+'/system/maintenance.html.custom'.
        If this file exists it will be used instead of the default capistrano ugly page
      DESC
      task :disable, :roles => :web, :except => { :no_release => true } do
        maint_file = "#{shared_path}/system/maintenance.html"
        require 'erb'
        on_rollback { run "rm #{shared_path}/system/maintenance.html" }

        reason = ENV['REASON']
        deadline = ENV['UNTIL']

        template = File.read(File.join(File.dirname(__FILE__), "templates", "maintenance.rhtml"))
        result = ERB.new(template).result(binding)

        put result, "#{shared_path}/system/maintenance.html.tmp", :mode => 0644
        run "if [ -f #{shared_path}/system/maintenance.html.custom ]; then; cp #{shared_path}/system/maintenance.html.custom #{maint_file}; else; #{shared_path}/system/maintenance.html.tmp #{maint_file}; fi"
      end
    end
  end

end