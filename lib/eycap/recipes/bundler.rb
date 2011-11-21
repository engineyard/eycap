Capistrano::Configuration.instance(:must_exist).load do
  namespace :bundler do
    desc "Automatically installed your bundled gems if a Gemfile exists"
    task :bundle_gems do
      run "mkdir -p #{shared_path}/bundled_gems"
      run "if [ -f #{release_path}/Gemfile ]; then cd #{release_path} && bundle install --without=test development --binstubs #{release_path}/bin --path #{shared_path}/bundled_gems; fi"
      run "ln -nfs #{release_path}/bin #{release_path}/ey_bundler_binstubs"  
    end
    after "deploy:symlink_configs","bundler:bundle_gems"
  end
end
