Capistrano::Configuration.instance(:must_exist).load do
  namespace :bundler do
    desc "Automatically installed your bundled gems if a Gemfile exists"
    task :bundle_gems do
      %w(vendor bin).each do |dirname|
        run "if [ -f Gemfile ]; then mkdir -p #{shared_path}/bundling/#{dirname} && cd #{release_path} && ln -s #{shared_path}/bundling/#{dirname} .; fi"
      end
      run "cd #{release_path} && if [ -f Gemfile ]; then gem bundle; fi"
    end
    after "deploy:symlink_configs","bundler:bundle_gems"
  end
end
