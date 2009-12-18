Capistrano::Configuration.instance(:must_exist).load do

  namespace :ssl do    
    namespace :create do
      desc "create 1024 bit csr and key for ssl certificates"
      task :short, :roles => :app, :except => {:no_release => true} do
        sudo "mkdir -p /data/ssl/"
        run "cd /data/ssl/"
        run "openssl req -new -nodes -days 365 -newkey rsa:1024 -subj '/C=US/ST=Oregon/L=Portland/CN=www.madboa.com' -keyout #{application}.com.key -out #{application}.com.csr"
      end
      
      desc "create 2048 bit csr and key for ssl certificates"
      task :long, :roles => :app, :except => {:no_release => true} do
        sudo "mkdir -p /data/ssl/"
        run "openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout #{application}.com.key -out #{application}.com.csr"
      end
    end    
  end
end