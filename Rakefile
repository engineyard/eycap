require 'rubygems'
require 'hoe'
require './lib/eycap'

Hoe.new('eycap', Eycap::VERSION) do |p|
  p.author = 'Engine Yard'
  p.email = 'tech@engineyard.com'
  p.summary = 'Capistrano tasks for Engine Yard slices'
  p.description = 'A bunch of useful recipes to help deployment to Engine Yard slices'
  p.url = 'http://eycap.rubyforge.org'
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.extra_deps << ['capistrano', '>= 2.2.0']
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r ./lib/eycap.rb"
end

task :coverage do
  system("rm -fr coverage")
  system("rcov test/test_*.rb")
  system("open coverage/index.html")
end

desc "Upload site to Rubyforge"
task :site do
end
