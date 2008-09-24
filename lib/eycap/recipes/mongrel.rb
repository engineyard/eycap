Capistrano::Configuration.instance(:must_exist).load do
  namespace :mongrel do
    desc <<-DESC
    Start Mongrel processes on the app server.  This uses the :use_sudo variable to determine whether to use sudo or not. By default, :use_sudo is
    set to true.
    DESC
    task :start, :roles => [:app], :except => {:mongrel => false} do
      sudo "/usr/bin/monit start all -g #{monit_group}"
    end

    desc <<-DESC
    Restart the Mongrel processes on the app server by starting and stopping the cluster. This uses the :use_sudo
    variable to determine whether to use sudo or not. By default, :use_sudo is set to true.
    DESC
    task :restart, :roles => [:app], :except => {:mongrel => false} do
      sudo "/usr/bin/monit restart all -g #{monit_group}"
    end

    desc <<-DESC
    Stop the Mongrel processes on the app server.  This uses the :use_sudo
    variable to determine whether to use sudo or not. By default, :use_sudo is
    set to true.
    DESC
    task :stop, :roles => [:app], :except => {:mongrel => false} do
      sudo "/usr/bin/monit stop all -g #{monit_group}"
    end
  end
end