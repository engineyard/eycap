Capistrano::Configuration.instance(:must_exist).load do

  namespace :db do
    task :backup_name, :only => { :primary => true } do
      now = Time.now
      run "mkdir -p #{shared_path}/db_backups"
      backup_time = [now.year,now.month,now.day,now.hour,now.min,now.sec].join('-')
      set :backup_file, "#{shared_path}/db_backups/#{environment_database}-snapshot-#{backup_time}.sql"
    end
  
    desc "Clone Production Database to Staging Database."
    task :clone_prod_to_staging, :roles => :db, :only => { :primary => true } do
      backup_name
      on_rollback { run "rm -f #{backup_file}" }
      run "mysqldump --add-drop-table -u #{dbuser} -h #{production_dbhost} -p#{dbpass} #{production_database} > #{backup_file}"
      run "mysql -u #{dbuser} -p#{dbpass} -h #{staging_dbhost} #{staging_database} < #{backup_file}"
      run "rm -f #{backup_file}"
    end
  
    desc "Backup your database to #{shared_path}/db_backups"
    task :dump, :roles => :db, :only => {:primary => true} do
      backup_name
      run "mysqldump --add-drop-table -u #{dbuser} -h #{environment_dbhost} -p#{dbpass} #{environment_database} | bzip2 -c > #{backup_file}.bz2"
    end
  end

end