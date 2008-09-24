Capistrano::Configuration.instance(:must_exist).load do

  namespace :juggernaut do
    desc "After update_code you want to symlink the juggernaut.yml file into place"
    task :symlink_configs, :roles => [:app], :except => {:no_release => true, :juggernaut => false} do
      run <<-CMD
        cd #{latest_release} &&
        ln -nfs #{shared_path}/config/juggernaut.yml #{latest_release}/config/juggernaut.yml &&
        ln -nfs #{shared_path}/config/juggernaut_hosts.yml #{latest_release}/config/juggernaut_hosts.yml
      CMD
    end
    [:start,:stop,:restart].each do |op|
      desc "#{op} juggernaut server"
      task op, :roles => [:app], :except => {:no_release => true, :juggernaut => false} do
        sudo "/usr/bin/monit #{op} all -g juggernaut_#{application}"
      end
    end
  end
end
