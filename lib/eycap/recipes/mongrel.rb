Capistrano::Configuration.instance(:must_exist).load do

  namespace :mongrel do
    desc <<-DESC
    Start Mongrel processes on the app server.  This uses the :use_sudo variable to determine whether to use sudo or not. By default, :use_sudo is
    set to true.
    DESC
    task :start, :roles => :app do
      sudo "/usr/bin/monit start all -g #{monit_group}"
    end

    desc <<-DESC
    Restart the Mongrel processes on the app server by starting and stopping the cluster. This uses the :use_sudo
    variable to determine whether to use sudo or not. By default, :use_sudo is set to true.
    DESC
    task :restart, :roles => :app do
      sudo "/usr/bin/monit restart all -g #{monit_group}"
    end

    desc <<-DESC
    Stop the Mongrel processes on the app server.  This uses the :use_sudo
    variable to determine whether to use sudo or not. By default, :use_sudo is
    set to true.
    DESC
    task :stop, :roles => :app do
      sudo "/usr/bin/monit stop all -g #{monit_group}"
    end
  
    desc "Get the status of your mongrels"
    task :status, :roles => :app do
      @monit_output ||= { }
      sudo "/usr/bin/monit status" do |channel, stream, data|
        @monit_output[channel[:server].to_s] ||= [ ]
        @monit_output[channel[:server].to_s].push(data.chomp)
      end
      @monit_output.each do |k,v|
        puts "#{k} -> #{'*'*55}"
        puts v.join("\n")
      end
    end
  end
end