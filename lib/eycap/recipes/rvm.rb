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
      parallel do |session|
        rvm_role = fetch(:rvm_require_role,"rvm")
        if exists?(:rvm_shell)
          session.when "in?(:#{rvm_role})", command_with_shell(<<-SHELL.split("\n").map(&:strip).join("; "), fetch(:rvm_shell))
            rvm alias create #{application} #{fetch(:rvm_ruby_string,nil)}
            rvm wrapper #{application} --no-links --all
          SHELL
        end
        session.else "true" # minimal NOOP
      end
    end

    after "bundler:bundle_gems","rvm:create_wrappers"
  end
end
