Engine Yard Capistrano Tasks
----------------------------

These tasks are designed for use specifically with Engine Yard slices.

They include convenience methods for managed a database, mongrel, nginx or other services.

Also included is a deployment strategy, :filtered_remote_cache, which speeds up deployment like :remote_cache,
but filters out .svn directory which are a security risk and write slowly to shared disks.

USAGE
-----

In your deploy.rb, simply include this line at the top:

require 'eycap/recipes'

To use filtered_remote_cache, simply:

set :deploy_via, :filtered_remote_cache
