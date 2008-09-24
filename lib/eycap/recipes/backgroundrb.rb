Capistrano::Configuration.instance(:must_exist).load do

  namespace :bdrb do
    desc "After update_code you want to reindex"
    task :reindex, :roles => [:app], :only => {:backgroundrb => true} do
      run "/engineyard/bin/searchd #{application} reindex"
    end
  
    desc "Start Backgroundrb"
    task :start, :roles => [:app], :only => {:backgroundrb => true} do
      sudo "/usr/bin/monit start all -g backgroundrb_#{application}"
    end
    desc "Stop Backgroundrb"
    task :stop, :roles => [:app], :only => {:backgroundrb => true} do
      sudo "/usr/bin/monit stop all -g backgroundrb_#{application}"
    end
    desc "Restart Backgroundrb"
    task :restart, :roles => [:app], :only => {:backgroundrb => true} do
      sudo "/usr/bin/monit restart all -g backgroundrb_#{application}"
    end        
  end

end
