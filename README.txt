= eycap

== DESCRIPTION:

Engine Yard capistrano tasks for use specifically with Engine Yard private cloud slices. They include convenience methods for managed a database, mongrel, nginx or other services.

Also included is a deployment strategy, :filtered_remote_cache, which speeds up deployment like :remote_cache, but filters out .svn directory which are a security risk and write slowly to shared disks.

== REQUIREMENTS:

* capistrano (http://capify.org) > 2.0.0, but recommended with > 2.2.0

* NOTE: If you're using a git repository we recommend capistrano 2.5.3 and greater.

== INSTALL:

  $ gem install gemcutter  # installs the gemcutter gem
  $ gem tumble             # puts gemcutter as your top source
  $ gem install eycap      # installs the latest eycap version

== SOURCE:
 
eycap's git repo is available on GitHub, which can be browsed at:
 
  http://github.com/engineyard/eycap
   
and cloned from:
   
  git://github.com/engineyard/eycap.git

== USAGE:

=== Include in capistrano

In your deploy.rb, simply include this line at the top:

require 'eycap/recipes'

=== Filtered remote cache

To use filtered_remote_cache, simply:

set :deploy_via, :filtered_remote_cache

== LICENSE:

Copyright (c) 2008-2009 Engine Yard

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.