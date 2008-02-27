Capistrano::Configuration.instance(:must_exist).load do

  namespace :sphinx do
    desc "After update_code you want to configure, then reindex"
    task :configure, :roles => :app, :only => {:sphinx => true}, :except => {:no_release => true} do
      run "/engineyard/bin/searchd #{application} configure"
    end

    desc "After configure you want to reindex"
    task :reindex, :roles => :app, :only => {:sphinx => true} do
      run "/engineyard/bin/searchd #{application} reindex"
    end
      
    desc "Start Sphinx Searchd"
    task :start, :roles => :app, :only => {:sphinx => true} do
      sudo "/usr/bin/monit start all -g sphinx_#{application}"
    end
    desc "Stop Sphinx Searchd"
    task :stop, :roles => :app, :only => {:sphinx => true} do
      sudo "/usr/bin/monit stop all -g sphinx_#{application}"
    end
    desc "Restart Sphinx Searchd"
    task :restart, :roles => :app, :only => {:sphinx => true} do
      sudo "/usr/bin/monit restart all -g sphinx_#{application}"
    end        

    desc "Symlink the sphinx config file"
    task :symlink, :roles => :app, :only => {:sphinx => true}, :except => {:no_release => true} do
      run "if [ -d #{release_path}/config/ultrasphinx ]; then mv #{release_path}/config/ultrasphinx #{release_path}/config/ultrasphinx.bak; fi"
      run "ln -nfs #{shared_path}/config/ultrasphinx #{release_path}/config/ultrasphinx"
    end
  end

end
