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
      run "mysqldump --add-drop-table -u #{dbuser} -h #{production_dbhost.gsub('-master', '-replica')} -p#{dbpass} #{production_database} > #{backup_file}"
      run "mysql -u #{dbuser} -p#{dbpass} -h #{staging_dbhost} #{staging_database} < #{backup_file}"
      run "rm -f #{backup_file}"
    end
  
    desc "Backup your database to shared_path+/db_backups"
    task :dump, :roles => :db, :only => {:primary => true} do
      backup_name
      run "mysqldump --add-drop-table -u #{dbuser} -h #{environment_dbhost.gsub('-master', '-replica')} -p#{dbpass} #{environment_database} | bzip2 -c > #{backup_file}.bz2"
    end
    
    desc "Sync your production database to your local workstation"
    task :clone_to_local, :roles => :db, :only => {:primary => true} do
      backup_name
      dump
      get "#{backup_file}.bz2", "/tmp/#{application}.sql.gz"
      development_info = YAML.load_file("config/database.yml")['development']
      run_str = "bzcat /tmp/#{application}.sql.gz | mysql -u #{development_info['username']} -p#{development_info['password']} -h #{development_info['host']} #{development_info['database']}"
      %x!#{run_str}!
    end
  end

end
