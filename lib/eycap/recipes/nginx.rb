Capistrano::Configuration.instance(:must_exist).load do

  namespace :nginx do 
    desc "Start Nginx on the app slices."
    task :start, :roles => :app, :except => {:nginx => false} do
      sudo "nohup /etc/init.d/nginx start 2>&1 | cat"
    end

    desc "Restart the Nginx processes on the app slices."
    task :restart , :roles => :app, :except => {:nginx => false} do
      sudo "nohup /etc/init.d/nginx restart 2>&1 | cat"
    end

    desc "Stop the Nginx processes on the app slices."
    task :stop , :roles => :app, :except => {:nginx => false} do
      sudo "/etc/init.d/nginx stop"
    end
    
    desc "Reload the Nginx config on the app slices."
    task :reload , :roles => :app, :except => {:nginx => false} do
      sudo "/etc/init.d/nginx reload"
    end

    desc "Upgrade the Nginx processes on the app slices."
    task :upgrade , :roles => :app, :except => {:nginx => false} do
      sudo "/etc/init.d/nginx upgrade"
    end

    desc "Test the Nginx config on the app slices."
    task :configtest , :roles => :app, :except => {:nginx => false} do
      sudo "/etc/init.d/nginx configtest"
    end

    desc "Tail the nginx error logs on the app slices"
    task :tail_error, :roles => :app, :except => {:nginx => false} do
      run "tail -f /var/log/engineyard/nginx/error.log" do |channel, stream, data|
        puts "#{channel[:server]}: #{data}" unless data =~ /^10\.[01]\.0/ # skips lb pull pages
        break if stream == :err    
      end
    end

  end
end