require File.join(File.dirname(__FILE__), "..", "lib", "ey_logger.rb")
Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :deploy do    
    # This is here to hook into the logger for deploy and deploy:long tasks
    ["deploy", "deploy:long"].each do |tsk|
      before(tsk) do
        Capistrano::EYLogger.setup( self, tsk )
        at_exit{ Capistrano::EYLogger.post_process if Capistrano::EYLogger.setup? }
      end
    end

    desc "Link the database.yml and mongrel_cluster.yml files into the current release path."
    task :symlink_configs, :roles => :app, :except => {:no_release => true} do
      run <<-CMD
        cd #{latest_release} &&
        ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml &&
        ln -nfs #{shared_path}/config/mongrel_cluster.yml #{latest_release}/config/mongrel_cluster.yml
      CMD
    end

    desc <<-DESC
      Run the migrate rake task. By default, it runs this in most recently \
      deployed version of the app. However, you can specify a different release \
      via the migrate_target variable, which must be one of :latest (for the \
      default behavior), or :current (for the release indicated by the \
      `current' symlink). Strings will work for those values instead of symbols, \
      too. You can also specify additional environment variables to pass to rake \
      via the migrate_env variable. Finally, you can specify the full path to the \
      rake executable by setting the rake variable. The defaults are:
 
      set :rake, "rake"
      set :framework, "merb"
      set :merb_env, "production"
      set :migrate_env, ""
      set :migrate_target, :latest
    DESC
    task :migrate, :roles => :db, :only => { :primary => true } do
      rake = fetch(:rake, "rake")
      
      framework = fetch(:framework, "rails")
      if framework.match(/^rails$/i)
        app_env = fetch(:rails_env, "production")
      else
        app_env = fetch("#{framework.downcase}_env".to_sym, "production")
      end
      
      migrate_env = fetch(:migrate_env, "")
      migrate_target = fetch(:migrate_target, :latest)
 
      directory = case migrate_target.to_sym
        when :current then current_path
        when :latest then current_release
        else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
        end
 
      run "cd #{directory}; #{rake} #{framework.upcase}_ENV=#{app_env} #{migrate_env} db:migrate"
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
        run "if [ -f #{shared_path}/system/maintenance.html.custom ]; then cp #{shared_path}/system/maintenance.html.custom #{maint_file}; else cp #{shared_path}/system/maintenance.html.tmp #{maint_file}; fi"
      end
    end

    namespace :notify do
      task :start, :roles => :app do
        begin
          run %(curl -X POST -d "application=#{application rescue 'unknown'}" http://weather.engineyard.com/`hostname`/deploy_start -fs)
        rescue
          puts "Warning: We couldn't notify EY of your deploy, but don't worry, everything is fine"
        end
      end

      task :stop, :roles => :app do
        begin
          run %(curl -X POST -d "application=#{application rescue 'unknown'}" http://weather.engineyard.com/`hostname`/deploy_stop -fs)
        rescue
          puts "Warning: We couldn't notify EY of your deploy finishing, but don't worry, everything is fine"
        end
      end
    end
  end

  ["deploy", "deploy:long"].each do |tsk|
    before(tsk, "deploy:notify:start")
    after(tsk, "deploy:notify:stop")
  end

end
