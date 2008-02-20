Capistrano::Configuration.instance(:must_exist).load do

  namespace :monit do
    desc "Get the status of your mongrels"
    task :status, :roles => :app do
      @monit_output ||= { }
      sudo "/usr/bin/monit status" do |channel, stream, data|
        @monit_output[channel[:server].to_s] ||= [ ]
        @monit_output[channel[:server].to_s].push(data.chomp)
      end
      @monit_output.each do |k,v|
        puts "#{k} -> #{'*'*55}"
        puts v.join("\n")
      end
    end
  end
end