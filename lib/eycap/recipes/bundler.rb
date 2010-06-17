Capistrano::Configuration.instance(:must_exist).load do
  namespace :bundler do
    desc "Automatically installed your bundled gems if a Gemfile exists"
    task :bundle_gems do
      run "if [ -f #{release_path}/Gemfile ]; then cd #{release_path} && bundle install --without=test,development; fi"
    end
    after "deploy:symlink_configs","bundler:bundle_gems"
  end
end