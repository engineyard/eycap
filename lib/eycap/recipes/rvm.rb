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
    task :create_wrappers, :roles => fetch(:rvm_require_role,"rvm") do
      run "rvm alias create #{application} #{rvm_ruby_string}"
      run "rvm wrapper #{application} --no-links --all" # works with 'rvm 1.19+'
    end

    after "bundler:bundle_gems","rvm:create_wrappers"
  end
end
