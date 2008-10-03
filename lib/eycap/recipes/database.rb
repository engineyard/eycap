Capistrano::Configuration.instance(:must_exist).load do

  namespace :db do
    task :backup_name, :roles => :db, :only => { :primary => true } do
      now = Time.now
      run "mkdir -p #{shared_path}/db_backups"
      backup_time = [now.year,now.month,now.day,now.hour,now.min,now.sec].join('-')
      set :backup_file, "#{shared_path}/db_backups/#{environment_database}-snapshot-#{backup_time}.sql"
    end
  
    desc "Clone Production Database to Staging Database."
    task :clone_prod_to_staging, :roles => :db, :only => { :primary => true } do
      backup_name
      on_rollback { run "rm -f #{backup_file}" }
      run("cat #{shared_path}/config/database.yml") { |channel, stream, data| @environment_info = YAML.load(data)[rails_env] }
      if @environment_info['adapter'] == 'mysql'
        run "mysqldump --add-drop-table -u #{dbuser} -h #{production_dbhost.gsub('-master', '-replica')} -p#{dbpass} #{production_database} > #{backup_file}"
        run "mysql -u #{dbuser} -p#{dbpass} -h #{staging_dbhost} #{staging_database} < #{backup_file}"
      else
        run "PGPASSWORD=#{dbpass} pg_dump -c -U #{dbuser} -h #{production_dbhost} -f #{backup_file} #{production_database}"
        run "PGPASSWORD=#{dbpass} psql -U #{dbuser} -h #{staging_dbhost} -f #{backup_file} #{staging_database}"
      end
      run "rm -f #{backup_file}"
    end
  
    desc "Backup your MySQL or PostgreSQL database to shared_path+/db_backups"
    task :dump, :roles => :db, :only => {:primary => true} do
      backup_name
      run("cat #{shared_path}/config/database.yml") { |channel, stream, data| @environment_info = YAML.load(data)[rails_env] }
      if @environment_info['adapter'] == 'mysql'
        run "mysqldump --add-drop-table -u #{dbuser} -h #{environment_dbhost.gsub('-master', '-replica')} -p#{dbpass} #{environment_database} | bzip2 -c > #{backup_file}.bz2"
      else
        run "PGPASSWORD=#{dbpass} pg_dump -c -U #{dbuser} -h #{environment_dbhost} #{environment_database} | bzip2 -c > #{backup_file}.bz2"
      end
    end
    
    desc "Sync your production database to your local workstation"
    task :clone_to_local, :roles => :db, :only => {:primary => true} do
      backup_name
      dump
      get "#{backup_file}.bz2", "/tmp/#{application}.sql.gz"
      development_info = YAML.load_file("config/database.yml")['development']
      if development_info['adapter'] == 'mysql'
        run_str = "bzcat /tmp/#{application}.sql.gz | mysql -u #{development_info['username']} -p#{development_info['password']} -h #{development_info['host']} #{development_info['database']}"
      else
        run_str = "PGPASSWORD=#{development_info['password']} bzcat /tmp/#{application}.sql.gz | psql -U #{development_info['username']} -h #{development_info['host']} #{development_info['database']}"
      end
      %x!#{run_str}!
    end
  end

end
