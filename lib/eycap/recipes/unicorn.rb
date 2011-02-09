Capistrano::Configuration.instance(:must_exist).load do
  namespace :unicorn do
    desc <<-DESC
    Start the Unicorn Master.  This uses the :use_sudo variable to determine whether to use sudo or not. By default, :use_sudo is set to true.
    DESC
    task :start, :roles => [:app], :except => {:unicorn => false} do
      sudo "/usr/bin/monit start all -g #{monit_group}"
    end

    desc <<-DESC
    Restart the Unicorn processes on the app server by starting and stopping the master. This uses the :use_sudo variable to determine whether to use sudo or not. By default, :use_sudo is set to true.
    DESC
    task :restart, :roles => [:app], :except => {:unicorn => false} do
      sudo "/usr/bin/monit restart all -g #{monit_group}"
    end

    desc <<-DESC
    Stop the Unicorn processes on the app server.  This uses the :use_sudo
    variable to determine whether to use sudo or not. By default, :use_sudo is
    set to true.
    DESC
    task :stop, :roles => [:app], :except => {:unicorn => false} do
      sudo "/usr/bin/monit stop all -g #{monit_group}"
    end

    desc <<-DESC
    Reloads the unicorn works gracefully - Use deploy task for deploys
    DESC
    task :reload, :roles => [:app], :except => {:unicorn => false} do
      sudo "/engineyard/bin/unicorn #{application} reload"
    end

    desc <<-DESC
    Adds a Unicorn worker - Beware of causing your host to swap, this setting isn't permanent
    DESC
    task :aworker, :roles => [:app], :except => {:unicorn => false} do
      sudo "/engineyard/bin/unicorn #{application} aworker"
    end

    desc <<-DESC
    Removes a unicorn worker (gracefully)
    DESC
    task :rworker, :roles => [:app], :except => {:unicorn => false} do
      sudo "/engineyard/bin/unicorn #{application} rworker"
    end

    desc <<-DESC
    Deploys app gracefully with USR2 and unicorn.rb combo
    DESC
    task :deploy, :roles => [:app], :except => {:unicorn => false} do
      sudo "/engineyard/bin/unicorn #{application} deploy"
    end
  end
end
