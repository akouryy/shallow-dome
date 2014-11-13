# encoding utf-8

require 'bundler'
Bundler.require
require './lib/browser'
require './lib/config_class_generator'
require './lib/symbol_plus'

module ShallowDome
  class ConfigManager
    ConfigClasses = []
    @added_class = []
    class << self
      def set_classes
        (ConfigClasses - @added_class).each do |x|
          x.add_config
          @added_class << x
        end
      end

      def load_configs
        set_classes unless (ConfigClasses - @added_class).empty?
        Dir.glob 'config/*.rb' do |x|
          ConfigClassGenerator.load x
        end
      end
    end
  end

  class Client
    ConfigManager::ConfigClasses << self

    def self.add_config
      oauth = ConfigClassGenerator.generate :oauth
      %i:consumer_key consumer_secret access_token access_token_secret:.each do |config|
        oauth.add_config config
      end
    end

    def initialize filepath = './config/oauth.rb'
      @client = Twitter::REST::Client.new (ConfigClassGenerator.get_one :oauth)
    end

    def tweet message
      @client.update message
    end
  end
end
