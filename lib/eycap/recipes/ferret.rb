Capistrano::Configuration.instance(:must_exist).load do

  namespace :ferret do
    desc "After update_code you want to symlink the index and ferret_server.yml file into place"
    task :symlink_configs, :roles => [:app], :except => {:no_release => true, :ferret => false} do
      run <<-CMD
        cd #{latest_release} &&
        ln -nfs #{shared_path}/config/ferret_server.yml #{latest_release}/config/ferret_server.yml &&
        if [ -d #{latest_release}/index ]; then mv #{latest_release}/index #{latest_release}/index.bak; fi &&
        ln -nfs #{shared_path}/index #{latest_release}/index
      CMD
    end
    [:start,:stop,:restart].each do |op|
      desc "#{op} ferret server"
      task op, :roles => [:app], :except => {:no_release => true, :ferret => false} do
        sudo "/usr/bin/monit #{op} all -g ferret_#{application}"
      end
    end
  end
end
