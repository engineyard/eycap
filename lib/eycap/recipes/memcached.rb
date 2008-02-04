Capistrano::Configuration.instance(:must_exist).load do

  namespace :memcached do
    
    desc "Start memcached"
    task :start, :roles => :app, :only => {:memcached => true} do
      sudo "/etc/init.d/memcached start"
    end
    desc "Stop memcached"
    task :stop, :roles => :app, :only => {:memcached => true} do
      sudo "/etc/init.d/memcached stop"
    end
    desc "Restart memcached"
    task :restart, :roles => :app, :only => {:memcached => true} do
      sudo "/etc/init.d/memcached restart"
    end        
  end

end
