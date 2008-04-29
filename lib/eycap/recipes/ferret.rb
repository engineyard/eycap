Capistrano::Configuration.instance(:must_exist).load do

  namespace :ferret do
    desc "After update_code you want to symlink the index and ferret_server.yml file into place"
    task :symlink_configs, :roles => :app, :except => {:no_release => true} do
      run <<-CMD
        cd #{release_path} &&
        ln -nfs #{shared_path}/config/ferret_server.yml #{release_path}/config/ferret_server.yml &&
        if [ -d #{release_path}/index ]; then mv #{release_path}/index #{release_path}/index.bak; fi &&
        ln -nfs #{shared_path}/index #{release_path}/index
      CMD
    end
    [:start,:stop,:restart].each do |op|
      desc "#{op} ferret server"
      task op, :roles => :app, :except => {:no_release => true} do
        sudo "/usr/bin/monit #{op} all -g ferret_#{application}"
      end
    end
  end
end
