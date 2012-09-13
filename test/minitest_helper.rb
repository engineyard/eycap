# Let's include the eycap gem.

require File.dirname(__FILE__) + '/../lib/eycap'

# This is a short and sweet way to bootstrap minitest.
# It also lets them keep it under a "service" if they want to make changes to
# the <tt>autorun</tt> method.
# https://github.com/seattlerb/minitest/blob/master/lib/minitest/autorun.rb

require 'minitest/autorun'

# This library has assertions and expectations already written that can help
# to test capistrano recipes.

require 'minitest-capistrano'