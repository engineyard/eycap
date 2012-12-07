# -*- encoding: utf-8 -*-
require File.expand_path('../lib/eycap/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Engine Yard", "Tyler Bird", "Matt Dolian", "Christopher Rigor", "Mike Riley", "Joel Watson", "Corey Donohoe", "Mutwin Kraus", "Erik Jones", "Daniel Neighman", "Dylan Egan", "Dan Peterson", "Tim Carey-Smith"]
  gem.email         = ["appsupport@engineyard.com"]
  gem.description   = %q{Capistrano recipes for the Engine Yard Managed platform.}
  gem.summary       = %q{Recipes that help automate the processes of the Engine Yard stack for users of the Managed platform.}
  gem.homepage      = "http://github.com/engineyard/eycap"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "eycap"
  gem.require_paths = ["lib"]
  gem.version       = Eycap::VERSION

  gem.add_dependency "capistrano", ">= 2.2.0"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "minitest"
  gem.add_development_dependency "minitest-capistrano"
end