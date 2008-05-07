Gem::Specification.new do |s|
  s.name = "eycap"
  s.version = "0.3.2"
  s.date = "2008-04-29"
  s.summary = "Capistrano tasks for Engine Yard slices"
  s.email = "tech@engineyard.com"
  s.homepage = "http://eycap.rubyforge.org"
  s.description = "A bunch of useful recipes to help deployment to Engine Yard slices"
  s.authors = ["Engine Yard"]

  s.require_paths = ["lib"]
  s.files = ["History.txt", "License.txt", "Manifest.txt", "README.txt", "Rakefile", "config/hoe.rb", "config/requirements.rb", "lib/capistrano/recipes/deploy/strategy/filtered_remote_cache.rb", "lib/eycap.rb", "lib/eycap/recipes.rb", "lib/eycap/recipes/backgroundrb.rb", "lib/eycap/recipes/database.rb", "lib/eycap/recipes/deploy.rb", "lib/eycap/recipes/ferret.rb", "lib/eycap/recipes/memcached.rb", "lib/eycap/recipes/mongrel.rb", "lib/eycap/recipes/monit.rb", "lib/eycap/recipes/nginx.rb", "lib/eycap/recipes/slice.rb", "lib/eycap/recipes/solr.rb", "lib/eycap/recipes/sphinx.rb", "lib/eycap/recipes/templates/maintenance.rhtml", "lib/eycap/recipes/tomcat.rb", "lib/eycap/lib/eylogger.rb","lib/eycap/lib/ey_logger_hooks.rb", "script/destroy", "script/generate", "script/txt2html", "setup.rb", "tasks/deployment.rake", "tasks/environment.rake", "tasks/website.rake", "test/test_eycap.rb", "test/test_helper.rb"]
  s.test_files = ["test/test_eycap.rb", "test/test_helper.rb"]

  s.has_rdoc = true
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "README.txt"]
  s.rdoc_options = ["--main", "README.txt"]

  s.rubyforge_project = "eycap"
  s.rubygems_version = "1.1.1"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.add_dependency("capistrano", ["> 2.2.0"])
end
