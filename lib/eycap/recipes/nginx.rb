Capistrano::Configuration.instance(:must_exist).load do

  namespace :nginx do 
    desc "Start Nginx on the app slices."
    task :start, :roles => :app do
      sudo "/etc/init.d/nginx start"
    end

    desc "Restart the Nginx processes on the app slices."
    task :restart , :roles => :app do
      sudo "/etc/init.d/nginx restart"
    end

    desc "Stop the Nginx processes on the app slices."
    task :stop , :roles => :app do
      sudo "/etc/init.d/nginx stop"
    end

    desc "Tail the nginx access logs for this application"
    task :tail, :roles => :app do
      run "tail -f /var/log/engineyard/nginx/#{application}.access.log" do |channel, stream, data|
        puts "#{channel[:server]}: #{data}" unless data =~ /^10\.[01]\.0/ # skips lb pull pages
        break if stream == :err    
      end
    end

    desc "Tail the nginx error logs on the app slices"
    task :tail_error, :roles => :app do
      run "tail -f /var/log/engineyard/nginx/error.log" do |channel, stream, data|
        puts "#{channel[:server]}: #{data}" unless data =~ /^10\.[01]\.0/ # skips lb pull pages
        break if stream == :err    
      end
    end

  end
end