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
      prod_info = YAML.load_file("config/database.yml")["production"]
      if prod_info['adapter'] == 'mysql'
        run "mysqldump --add-drop-table -u #{dbuser} -h #{production_dbhost.gsub('-master', '-replica')} -p#{dbpass} #{production_database} > #{backup_file}"
        run "mysql -u #{dbuser} -p#{dbpass} -h #{staging_dbhost} #{staging_database} < #{backup_file}"
      else
        run "pg_dump -c -U #{dbuser} -h #{production_dbhost} -W #{dbpass} #{production_database} > #{backup_file}"
        run "psql -U #{dbuser} -W #{dbpass} -h #{staging_dbhost} #{staging_database} < #{backup_file}"
      end
      run "rm -f #{backup_file}"
    end
  
    desc "Backup your database to shared_path+/db_backups"
    task :dump, :roles => :db, :only => {:primary => true} do
      backup_name
      environment_info = YAML.load_file("config/database.yml")[rails_env]
      if environment_info['adapter'] == 'mysql'
        run "mysqldump --add-drop-table -u #{dbuser} -h #{environment_dbhost.gsub('-master', '-replica')} -p#{dbpass} #{environment_database} | bzip2 -c > #{backup_file}.bz2"
      else
        run "pg_dump -c -U #{dbuser} -h #{environment_dbhost} -W #{dbpass} #{environment_database} | bzip2 -c > #{backup_file}.bz2"
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
        run_str = "bzcat /tmp/#{application}.sql.gz | psql -U #{development_info['username']} -W #{development_info['password']} -h #{development_info['host']} #{development_info['database']}"
      end
      %x!#{run_str}!
    end
  end

end
