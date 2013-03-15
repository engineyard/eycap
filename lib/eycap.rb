require 'eycap/lib/ey_logger'
require 'eycap/lib/ey_logger_hooks'
require 'eycap/recipes/apache'
require 'eycap/recipes/backgroundrb'
require 'eycap/recipes/bundler'
require 'eycap/recipes/database'
require 'eycap/recipes/delayed_job'
require 'eycap/recipes/deploy'
require 'eycap/recipes/ferret'
require 'eycap/recipes/juggernaut'
require 'eycap/recipes/memcached'
require 'eycap/recipes/mongrel'
require 'eycap/recipes/monit'
require 'eycap/recipes/nginx'
require 'eycap/recipes/passenger'
require 'eycap/recipes/resque'
require 'eycap/recipes/rvm'
require 'eycap/recipes/slice'
require 'eycap/recipes/solr'
require 'eycap/recipes/sphinx'
require 'eycap/recipes/ssl'
require 'eycap/recipes/tomcat'
require 'eycap/recipes/unicorn'

Capistrano::Configuration.instance(:must_exist).load do
  default_run_options[:pty] = true if respond_to?(:default_run_options)
  set :keep_releases, 3
  set :runner, defer { user }
end
