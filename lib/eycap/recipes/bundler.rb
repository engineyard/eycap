Capistrano::Configuration.instance(:must_exist).load do

set :bundle_without, "test development" unless exists?(:bundle_without)

  namespace :bundler do
    desc "Automatically installed your bundled gems if a Gemfile exists"
    task :bundle_gems, :roles => :app, :except => {:no_bundle => true} do
      only_with_rvm = <<-SHELL
        if [ -f #{release_path}/Gemfile ]
        then cd #{release_path} && bundle install --without=#{bundle_without} --system
        fi
      SHELL
      only_without_rvm = <<-SHELL
        mkdir -p #{shared_path}/bundled_gems
        if [ -f #{release_path}/Gemfile ]
        then cd #{release_path} && bundle install --without=#{bundle_without} --binstubs #{release_path}/bin --path #{shared_path}/bundled_gems --quiet  --deployment
        fi
        if [ ! -h #{release_path}/bin ]
        then ln -nfs #{release_path}/bin #{release_path}/ey_bundler_binstubs
        fi
      SHELL
      run_rvm_or only_with_rvm, only_without_rvm
    end
    task :symlink_bundle_config, :roles => :app do
      run_rvm_or "true", "mkdir -p #{shared_path}/bundle && ln -sf #{shared_path}/bundle #{release_path}/.bundle"
    end
    before "bundler:bundle_gems","bundler:symlink_bundle_config"
    after "deploy:symlink_configs","bundler:bundle_gems"
  end
end
