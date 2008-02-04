Capistrano::Configuration.instance(:must_exist).load do

  namespace :slice do
    desc "Tail the Rails production log for this environment"
    task :tail_production_logs, :roles => :app do
      run "tail -f #{shared_path}/log/#{rails_env}.log" do |channel, stream, data|
        puts  # for an extra line break before the host name
        puts "#{channel[:server]} -> #{data}" 
        break if stream == :err    
      end
    end
    desc "Tail the Mongrel logs this environment"
    task :tail_mongrel_logs, :roles => :app do
      run "tail -f #{shared_path}/log/mongrel*.log" do |channel, stream, data|
        puts  # for an extra line break before the host name
        puts "#{channel[:server]} -> #{data}" 
        break if stream == :err    
      end
    end
  end
end
