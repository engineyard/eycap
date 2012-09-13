require 'minitest_helper'

class TestEycap < MiniTest::Unit::TestCase

  describe "first test" do
    Capistrano::Configuration.instance = Capistrano::Configuration.new
    load_capistrano_recipe(Capistrano::Recipes::Default)

    it 'loads the specified recipe into the instance configuration' do
      Capistrano::Configuration.instance.must_have_task "default"
    end
    
  end

end