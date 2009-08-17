Capistrano::Configuration.instance(:must_exist).load do

  namespace :sphinx do
    desc "After update_code you want to configure, then reindex"
    task :configure, :roles => [:app], :only => {:sphinx => true}, :except => {:no_release => true} do
      run "/engineyard/bin/searchd #{application} configure"
    end

    desc "After configure you want to reindex"
    task :reindex, :roles => [:app], :only => {:sphinx => true} do
      run "/engineyard/bin/searchd #{application} reindex"
    end

    desc "Start Sphinx Searchd"
    task :start, :roles => [:app], :only => {:sphinx => true} do
      sudo "/usr/bin/monit start all -g sphinx_#{application}"
    end

    desc "Stop Sphinx Searchd"
    task :stop, :roles => [:app], :only => {:sphinx => true} do
      sudo "/usr/bin/monit stop all -g sphinx_#{application}"
    end

    desc "Restart Sphinx Searchd"
    task :restart, :roles => [:app], :only => {:sphinx => true} do
      sudo "/usr/bin/monit restart all -g sphinx_#{application}"
    end

    task :symlink, :roles => [:app], :only => {:sphinx => true}, :except => {:no_release => true} do
      run "if [ -d #{latest_release}/config/ultrasphinx ]; then mv #{latest_release}/config/ultrasphinx #{latest_release}/config/ultrasphinx.bak; fi"
      run "ln -nfs #{shared_path}/config/ultrasphinx #{latest_release}/config/ultrasphinx"
    end  
  end

  namespace :acts_as_sphinx do
    desc "After update_code you to to reindex"
    task :reindex, :roles => [:app], :only => {:sphinx => true} do
      run "/engineyard/bin/acts_as_sphinx_searchd #{application} reindex"
    end
  end

  namespace :thinking_sphinx do
    desc "After update_code you want to configure, then reindex"
    task :configure, :roles => [:app], :only => {:sphinx => true}, :except => {:no_release => true} do
      run "/engineyard/bin/thinking_sphinx_searchd #{application} configure"
    end

    desc "After configure you want to reindex"
    task :reindex, :roles => [:app], :only => {:sphinx => true} do
      run "/engineyard/bin/thinking_sphinx_searchd #{application} reindex"
    end

    task :symlink, :roles => [:app], :only => {:sphinx => true}, :except => {:no_release => true} do
      run "if [ -d #{latest_release}/config/thinkingsphinx ]; then mv #{latest_release}/config/thinkingsphinx #{latest_release}/config/thinkingsphinx.bak; fi"
      run "ln -nfs #{shared_path}/config/thinkingsphinx #{latest_release}/config/thinkingsphinx"
      run "ln -nfs #{shared_path}/config/sphinx.yml #{latest_release}/config/sphinx.yml"
    end
  end

  namespace :ultrasphinx do
    desc "After update_code you want to configure, then reindex"
    task :configure, :roles => [:app], :only => {:sphinx => true}, :except => {:no_release => true} do
      run "/engineyard/bin/ultrasphinx_searchd #{application} configure"
    end

    desc "After configure you want to reindex"
    task :reindex, :roles => [:app], :only => {:sphinx => true} do
      run "/engineyard/bin/ultrasphinx_searchd #{application} reindex"
    end   

    task :symlink, :roles => [:app], :only => {:sphinx => true}, :except => {:no_release => true} do
      run "if [ -d #{latest_release}/config/ultrasphinx ]; then mv #{latest_release}/config/ultrasphinx #{latest_release}/config/ultrasphinx.bak; fi"
      run "ln -nfs #{shared_path}/config/ultrasphinx #{latest_release}/config/ultrasphinx"
    end    
  end
end
