require 'capistrano/recipes/deploy/scm/base'
require 'capistrano/recipes/deploy/strategy/remote'

module Capistrano
  module Deploy
    module SCM
      class Subversion < Base
        def switch(revision, checkout)
          "cd #{checkout} && #{scm :switch, verbose, authentication, "-r#{revision}", repository}"
        end
      end
    end
    
    module Strategy

      # Implements the deployment strategy that keeps a cached checkout of
      # the source code on each remote server. Each deploy simply updates the
      # cached checkout, and then filters a copy through tar to remove unwanted .svn directories,
      # finally leaving a pristeen, export-like copy at the destination.
      class FilteredRemoteCache < Remote
        # Executes the SCM command for this strategy and writes the REVISION
        # mark file to each host.
        def deploy!
          update_repository_cache
          tar_copy_repository_cache
        end

        def check!
          super.check do |d|
            d.remote.writable(shared_path)
          end
        end

        private

          def repository_cache
            configuration[:repository_cache] || "/var/cache/engineyard/#{configuration[:application]}"
          end

          def update_repository_cache
            logger.trace "checking if the cached copy repository root matches this deploy, then updating it"
            command = "if [ -d #{repository_cache} ] && ! echo '#{configuration[:repository]}' | grep -q `svn info #{repository_cache} | grep 'Repository Root' | awk '{print $3}'`; then " + 
              "rm -rf #{repository_cache} && #{source.checkout(revision, repository_cache)}; " + 
              "elif [ -d #{repository_cache} ]; then #{source.switch(revision, repository_cache)}; " +
              "else #{source.checkout(revision, repository_cache)}; fi"
            scm_run(command)
          end

          def tar_copy_repository_cache
            logger.trace "copying and filtering .svn via tar from cached version to #{configuration[:release_path]}"
            run "mkdir #{configuration[:release_path]} && tar c --exclude=#{configuration[:filter_spec] || ".svn"} -C #{repository_cache} . | tar xC #{configuration[:release_path]} && #{mark}"
          end
      end

    end
  end
end
