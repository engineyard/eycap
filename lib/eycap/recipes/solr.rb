Capistrano::Configuration.instance(:must_exist).load do

  namespace :solr do
    desc "After update_code you want to symlink the index and ferret_server.yml file into place"
    task :symlink_configs, :roles => [:app], :except => {:no_release => true} do
      run <<-CMD
        cd #{latest_release} && ln -nfs #{shared_path}/config/solr.yml #{latest_release}/config/solr.yml
      CMD
    end
    
    [:start,:stop,:restart].each do |op|
      desc "#{op} ferret server"
      task op, :roles => [:app], :only => {:solr => true} do
        sudo "/usr/bin/monit #{op} all -g solr_#{application}"
      end
    end
    
    namespace :tail do
      desc "Tail the Solr logs this environment"
      task :logs, :roles => [:app], :only => {:solr => true} do
        run "tail -f /var/log/engineyard/solr/#{application}.log" do |channel, stream, data|
          puts  # for an extra line break before the host name
          puts "#{channel[:server]} -> #{data}" 
          break if stream == :err    
        end
      end
      desc "Tail the Solr error logs this environment"
      task :errors, :roles => [:app], :only => {:solr => true} do
        run "tail -f /var/log/engineyard/solr/#{application}.err.log" do |channel, stream, data|
          puts  # for an extra line break before the host name
          puts "#{channel[:server]} -> #{data}" 
          break if stream == :err    
        end
      end
    end    
  end
end
