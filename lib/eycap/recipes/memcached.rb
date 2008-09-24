Capistrano::Configuration.instance(:must_exist).load do
  namespace :memcached do 
    desc "Start memcached"
    task :start, :roles => [:app], :only => {:memcached => true} do
      sudo "/etc/init.d/memcached start"
    end
    desc "Stop memcached"
    task :stop, :roles => [:app], :only => {:memcached => true} do
      sudo "/etc/init.d/memcached stop"
    end
    desc "Restart memcached"
    task :restart, :roles => [:app], :only => {:memcached => true} do
      sudo "/etc/init.d/memcached restart"
    end        
    desc "Symlink the memcached.yml file into place if it exists"
    task :symlink_configs, :roles => [:app], :only => {:memcached => true }, :except => { :no_release => true } do
      run "if [ -f #{shared_path}/config/memcached.yml ]; then ln -nfs #{shared_path}/config/memcached.yml #{latest_release}/config/memcached.yml; fi"
    end
  end
end
