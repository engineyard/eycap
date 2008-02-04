desc 'Release the website and new gem version'
task :deploy => [:check_version] do
#  puts "Remember to create SVN tag:"
#  puts "svn copy svn+ssh://#{rubyforge_username}@rubyforge.org/var/svn/#{PATH}/trunk " +
#    "svn+ssh://#{rubyforge_username}@rubyforge.org/var/svn/#{PATH}/tags/REL-#{VERS} "
#  puts "Suggested comment:"
  puts "Deploying to EY gemserver. The error about the directory in /tmp is normal, don't worry!"
  puts `scp pkg/eycap-#{VERS}.gem ey01-s00235:/data/gems/gems`
  puts `ssh ey01-s00235 "cd /data/gems; gem generate_index /data/gems"`
  puts "Tagging release #{CHANGES}"
end

desc 'Runs tasks website_generate and install_gem as a local deployment of the gem'
task :local_deploy => [:website_generate, :install_gem]

task :check_version do
  unless ENV['VERSION']
    puts 'Must pass a VERSION=x.y.z release version'
    exit
  end
  unless ENV['VERSION'] == VERS
    puts "Please update your version.rb to match the release version, currently #{VERS}"
    exit
  end
end

desc 'Install the package as a gem, without generating documentation(ri/rdoc)'
task :install_gem_no_doc => [:clean, :package] do
  sh "#{'sudo ' unless Hoe::WINDOZE }gem install pkg/*.gem --no-rdoc --no-ri"
end

namespace :manifest do
  desc 'Recreate Manifest.txt to include ALL files'
  task :refresh do
    `rake check_manifest | patch -p0 > Manifest.txt`
  end
end
