# Let's include the eycap gem.
# FIXME: when you uncomment the require to bring in eycap it starts to error:
#
# capistrano/lib/capistrano/configuration/loading.rb:18:
# in `instance': Please require this file from within a Capistrano recipe (LoadError)
#
# require File.dirname(__FILE__) + '/../lib/eycap'

# This is a short and sweet way to bootstrap minitest.
# It also lets them keep it under a "service" if they want to make changes to
# the <tt>autorun</tt> method.
# https://github.com/seattlerb/minitest/blob/master/lib/minitest/autorun.rb

require 'rubygems'
require 'bundler/setup'

require 'minitest/autorun'

# This library has assertions and expectations already written that can help
# to test capistrano recipes.
require 'minitest-capistrano'

# Let's add capistrano, since that's what we need to deploy.
require 'capistrano'

# Load a default fixture capistrano object.
require 'fixtures/recipes/default'
