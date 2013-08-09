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
        then cd #{release_path} && bundle install --without=#{bundle_without} --binstubs #{release_path}/bin --path #{shared_path}/bundled_gems --quiet
        fi
        if [ ! -h #{release_path}/bin ]
        then ln -nfs #{release_path}/bin #{release_path}/ey_bundler_binstubs
        fi
      SHELL
      run_rvm_or only_with_rvm, only_without_rvm
    end
    task :bundle_config, :roles => :app, :only => {:no_bundle => true} do
      run_rvm_or "true", <<-SHELL
        bundle config --local BIN /data/#{application}/releases/#{release_path}/bin
        bundle config --local PATH /data/#{application}/shared/bundled_gems
        bundle config --local DISABLE_SHARED_GEMS "1"
        bundle config --local WITHOUT test:development
      SHELL
    end
    after "deploy:symlink_configs","bundler:bundle_gems"
    after "bundler:bundle_gems","bundler:bundle_config"
  end
end
