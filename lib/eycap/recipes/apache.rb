Capistrano::Configuration.instance(:must_exist).load do
  namespace :apache do
    [:stop, :start, :restart, :reload].each do |action|
      desc "#{action.to_s.capitalize} Apache"
      task action, :roles => :web do
        sudo "/etc/init.d/apache2 #{action.to_s}"
      end
    end
  end
end