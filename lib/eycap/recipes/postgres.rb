require 'erb'

Capistrano::Configuration.instance(:must_exist).load do

  namespace :postgres do
    task :backup_name, :roles => :db, :only => { :primary => true } do
      now = Time.now
      run "mkdir -p #{shared_path}/db_backups"
      backup_time = [now.year,now.month,now.day,now.hour,now.min,now.sec].join('-')
      set :backup_file, "#{shared_path}/db_backups/#{environment_database}-snapshot-#{backup_time}.sql"
    end

    desc "Clone production database to staging database."
    task :clone_prod_to_staging, :roles => :db, :only => { :primary => true } do

      # This task currently runs only on traditional EY offerings.
      # You need to have both a production and staging environment defined in
      # your deploy.rb file.

      backup_name unless exists?(:backup_file)
      run("cat #{shared_path}/config/database.yml") { |channel, stream, data| @environment_info = YAML.load(data)[rails_env] }
      dump
      run "gunzip < #{backup_file}.gz | psql -W -U #{dbuser} -h #{staging_dbhost} #{staging_database}" do |ch, stream, out|
         ch.send_data "#{dbpass}\n" if out=~ /^Password/
      end
      run "rm -f #{backup_file}.gz"
    end

    desc "Backup your PostgreSQL database to shared_path/db_backups."
    task :dump, :roles => :db, :only => {:primary => true} do
      backup_name unless exists?(:backup_file)
      on_rollback { run "rm -f #{backup_file}" }
      run("cat #{shared_path}/config/database.yml") { |channel, stream, data| @environment_info = YAML.load(data)[rails_env] }      
      run "pg_dump -W -c -U #{dbuser} -h #{environment_dbhost} #{environment_database} | gzip -c > #{backup_file}.gz" do |ch, stream, out |
         ch.send_data "#{dbpass}\n" if out=~ /^Password:/
      end
    end

    desc "Sync your production database to your local workstation."
    task :clone_to_local, :roles => :db, :only => {:primary => true} do
      backup_name unless exists?(:backup_file)
      dump
      get "#{backup_file}.gz", "/tmp/#{application}.sql.gz"
      development_info = YAML.load(ERB.new(File.read('config/database.yml')).result)['development']
      run_str  = ""
      run_str += "PGPASSWORD=#{development_info['password']} " if development_info['password']
      run_str += "gunzip < /tmp/#{application}.sql.gz | psql -U #{development_info['username']} "
      run_str += "-h #{development_info['host']} "             if development_info['host']
      run_str += development_info['database']
      %x!#{run_str}!
      run "rm -f #{backup_file}.gz"
    end
  end

end
