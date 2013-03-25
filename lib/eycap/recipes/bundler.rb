Capistrano::Configuration.instance(:must_exist).load do

set :bundle_without, "test development" unless exists?(:bundle_without)

  namespace :bundler do
    desc "Automatically installed your bundled gems if a Gemfile exists"
    task :bundle_gems, :roles => :app, :except => {:no_bundle => true} do
      parallel do |session|
        rvm_role = fetch(:rvm_require_role,"rvm")
        if exists?(:rvm_shell)
          session.when "in?(:#{rvm_role})", command_with_shell(<<-SHELL.split("\n").map(&:strip).join("; "), fetch(:rvm_shell))
            if [ -f #{release_path}/Gemfile ]
            then cd #{release_path} && bundle install --without=#{bundle_without} --system
            fi
          SHELL
        end
        session.else <<-SHELL.split("\n").map(&:strip).join("; ")
          mkdir -p #{shared_path}/bundled_gems
          if [ -f #{release_path}/Gemfile ]
          then cd #{release_path} && bundle install --without=#{bundle_without} --binstubs #{release_path}/bin --path #{shared_path}/bundled_gems
          fi
          if [ ! -h #{release_path}/bin ]
          then ln -nfs #{release_path}/bin #{release_path}/ey_bundler_binstubs
          fi
        SHELL
      end
    end
    after "deploy:symlink_configs","bundler:bundle_gems"
  end
end
