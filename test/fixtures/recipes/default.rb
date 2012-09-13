require 'capistrano'

module Capistrano::Recipes
  module Default
    def self.load_into(configuration)
      configuration.load do
        task :default do
          set :message, 'this is a fixture class of a default Capistrano object'
          message
        end
      end
    end
  end
end