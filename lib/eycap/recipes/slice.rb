Capistrano::Configuration.instance(:must_exist).load do

  namespace :slice do
    desc "Tail the Rails logs for your environment"
    task :tail_environment_logs, :roles => :app do
      run "tail -f #{shared_path}/log/#{rails_env}.log" do |channel, stream, data|
        puts  # for an extra line break before the host name
        puts "#{channel[:server]} -> #{data}" 
        break if stream == :err    
      end
    end
    desc "Tail the Mongrel logs for your environment"
    task :tail_mongrel_logs, :roles => :app do
      run "tail -f #{shared_path}/log/mongrel*.log" do |channel, stream, data|
        puts  # for an extra line break before the host name
        puts "#{channel[:server]} -> #{data}" 
        break if stream == :err    
      end
    end
    desc "Tail the apache logs for your environment"
    task :tail_apache_logs, :roles => [:app, :web] do
      run "tail -f /var/log/apache2/#{application}.*.access.log" do |channel, stream, data|
        puts # line break
        puts "#{channel[:server]} -> #{data}"
        break if stream == :err
      end
    end
  end
end
