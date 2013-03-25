# The bundler rake tasks help automate the distribution of this gem.
require 'bundler'
Bundler::GemHelper.install_tasks

# Define a default 'rake' alias for minitest so that when you type
# rake in the root of the <tt>eycap</tt> folder you will run the tests.
# https://github.com/jimweirich/rake/blob/master/lib/rake/testtask.rb

require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test" << "lib"
  t.pattern = "test/**/*_test.rb"
end

task :default => :test
