Capistrano::Configuration.instance(:must_exist).load do
  namespace :rvm do
    desc <<-DESC
      Create rvm wrappers for background tasks,
      in any script adding rvm support looks like:

      rvm_path=/usr/local/rvm
      if [[ -s "$rvm_path/environments/${application}" ]]
      then PATH="$rvm_path/wrappers/${application}:$PATH"
      fi
    DESC
    task :create_wrappers, :roles => :app, :except => {:no_bundle => true} do
      run_rvm_or <<-SHELL
        rvm alias create #{application} #{fetch(:rvm_ruby_string,nil)}
        rvm wrapper #{application} --no-links --all
      SHELL
    end

    after "bundler:bundle_gems","rvm:create_wrappers"
  end
end
