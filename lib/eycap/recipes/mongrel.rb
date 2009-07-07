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

    desc <<-DESC
    Start mongrels in a loop, with a defer of [default] 30 seconds between each single mongrel restart. 
    DESC
    task :rolling_restart, :roles => [:app], :except => {:mongrel => false} do

      set :mongrel_restart_delay, 30

      # need a script due to weird escapes run by sudo "X".
        script = File.open("/tmp/rolling.reboot", 'w+')
        script.puts "#!/bin/bash"
        script.puts "export monit_group=#{monit_group}" 
        script.puts "export mongrel_restart_delay=#{mongrel_restart_delay}" 
        # here's the need for single quoted - sed ? - (no escaping).
        script.puts 'for port in $(monit summary | grep mongrel | sed -r \'s/[^0-9]*([0-9]+).*/\1/\'); do echo "Executing monit restart mongrel_${monit_group}_${port}"; /usr/bin/monit restart mongrel_${monit_group}_${port}; echo "sleeping $mongrel_restart_delay"; sleep ${mongrel_restart_delay}; done'
        script.close

        upload(script.path, script.path, :via=> :scp)

        #it's in the script, on the remote server, execute it.
        sudo "chmod +x #{script.path}"
        sudo "#{script.path}"
        #cleanup 
        sudo "rm #{script.path}"
        require 'fileutils' ; FileUtils.rm(script.path)
        puts "Done."
    end

  end #namespace
end #Capistrano::Configuration
