Capistrano::Configuration.instance(:must_exist).load do
  namespace :tomcat do 
    desc "Start tomcat"
    task :start, :roles => [:app], :only => {:tomcat => true} do
      sudo "/etc/init.d/tomcat start"
    end
    desc "Stop tomcat"
    task :stop, :roles => [:app], :only => {:tomcat => true} do
      sudo "/etc/init.d/tomcat stop"
    end
    desc "Restart tomcat"
    task :restart, :roles => [:app], :only => {:tomcat => true} do
      sudo "/etc/init.d/tomcat restart"
    end
  end
end