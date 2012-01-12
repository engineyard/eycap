require 'erb'

Capistrano::Configuration.instance(:must_exist).load do

  namespace :db do
    task :backup_name, :roles => :db, :only => { :primary => true } do
      now = Time.now
      run "mkdir -p #{shared_path}/db_backups"
      backup_time = [now.year,now.month,now.day,now.hour,now.min,now.sec].join('-')
      set :backup_file, "#{shared_path}/db_backups/#{environment_database}-snapshot-#{backup_time}.sql"
    end

    desc "Clone Production MySQL, PostgresSQL or MongoDB database to staging database."
    task :clone_prod_to_staging, :roles => :db, :only => { :primary => true } do

      # This task currently runs only on traditional EY offerings.
      # You need to have both a production and staging environment defined in
      # your deploy.rb file.
      #
      # For Mongo: - dev-db/mongodb-bin package required on slice where :role => :db
      #            - slice must also have a mongoid.yml file in shared/config

      backup_name unless exists?(:backup_file)
      dump
      
      if remote_file_exists?("#{shared_path}/config/mongoid.yml") then
        backup_file.slice!(".sql")
        dbstr = exists?(:dbuser) ? "-u #{dbuser} -p #{dbpass}" : ""
        run "tar xf #{backup_file}.tar && cd #{backup_file}"
        run "mongo #{staging_database} -h #{staging_dbhost} -h #{staging_dbhost} --eval 'db.dropDatabase()'"
        run "mongorestore -h #{staging_dbhost} -h #{staging_dbhost}-d #{staging_database} --drop #{backup_file}/#{production_database}"
        run "cd / && tar cf #{backup_file}.tar #{backup_file[1..-1]}/*"
      else
        run("cat #{shared_path}/config/database.yml") { |channel, stream, data| @environment_info = YAML.load(data)[rails_env] }

        if ['mysql', 'mysql2'].include? @environment_info['adapter']
          run "gunzip < #{backup_file}.gz | mysql -u #{dbuser} -p -h #{staging_dbhost} #{staging_database}" do |ch, stream, out|
            ch.send_data "#{dbpass}\n" if out=~ /^Enter password:/
          end
        else
          run "gunzip < #{backup_file}.gz | psql -W -U #{dbuser} -h #{staging_dbhost} #{staging_database}" do |ch, stream, out|
            ch.send_data "#{dbpass}\n" if out=~ /^Password/
          end
        end
      end
      run "rm -f #{backup_file}.gz"
    end

    desc "Backup your MySQL, PostgreSQL or MongoDB database to shared_path+/db_backups"
    task :dump, :roles => :db, :only => {:primary => true} do
      
      # Updated for MongoDB:
      # If you wish to dump from a Mongo slave, set :environment_slave_dbhost in the role
      
      backup_name unless exists?(:backup_file)
      on_rollback { run "rm -f #{backup_file}" }
      
      if remote_file_exists?("#{shared_path}/config/mongoid.yml") then
        backup_file.slice!(".sql")
        dbstr = exists?(:dbuser) ? "-u #{dbuser} -p #{dbpass}" : ""
        set :environment_slave_dbhost, environment_dbhost unless exists?(:environment_slave_dbhost)
        run "mongodump -o #{backup_file} -d #{environment_database} --host #{environment_slave_dbhost} #{dbstr}"
        run "cd / && tar cf #{backup_file}.tar #{backup_file[1..-1]}/*"
      else 
        run("cat #{shared_path}/config/database.yml") { |channel, stream, data| @environment_info = YAML.load(data)[rails_env] }
      
        if ['mysql', 'mysql2'].include? @environment_info['adapter']
          dbhost = @environment_info['host']
          if rails_env == "production"
            dbhost = environment_dbhost.sub('-master', '') + '-replica' if dbhost != 'localhost' # added for Solo offering, which uses localhost
          end
          run "mysqldump --add-drop-table -u #{dbuser} -h #{dbhost} -p #{environment_database} | gzip -c > #{backup_file}.gz" do |ch, stream, out |
             ch.send_data "#{dbpass}\n" if out=~ /^Enter password:/
          end
        else
          run "pg_dump -W -c -U #{dbuser} -h #{environment_dbhost} #{environment_database} | gzip -c > #{backup_file}.gz" do |ch, stream, out |
             ch.send_data "#{dbpass}\n" if out=~ /^Password:/
          end
        end
      end
    end

    desc "Sync your production database to your local workstation - MySQL and PostgresSQL only"
    task :clone_to_local, :roles => :db, :only => {:primary => true} do
      backup_name unless exists?(:backup_file)
      dump
      get "#{backup_file}.gz", "/tmp/#{application}.sql.gz"
      development_info = YAML.load(ERB.new(File.read('config/database.yml')).result)['development']

      if ['mysql', 'mysql2'].include? development_info['adapter']
        run_str = "gunzip < /tmp/#{application}.sql.gz | mysql -u #{development_info['username']} --password='#{development_info['password']}' -h #{development_info['host']} #{development_info['database']}"
      else
        run_str  = ""
        run_str += "PGPASSWORD=#{development_info['password']} " if development_info['password']
        run_str += "gunzip < /tmp/#{application}.sql.gz | psql -U #{development_info['username']} "
        run_str += "-h #{development_info['host']} "             if development_info['host']
        run_str += development_info['database']
      end
      %x!#{run_str}!
      run "rm -f #{backup_file}.gz"
    end
  end

end
