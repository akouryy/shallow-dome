# encoding utf-8

require 'bundler'
Bundler.require
require './lib/browser'
require './lib/config_class_generator'
require './lib/symbol_plus'

module TwitterClient
  class Client
    ClientOptions = %i:consumer_key consumer_secret access_token access_token_secret:
    attr_reader :client

    def initialize filepath = './config/oauth.rb'
      @oauth = ConfigClassGenerator.new :oauth
      ClientOptions.each do |config|
        @oauth.add_config config
      end
      @config = ConfigClassGenerator.load filepath
      @client = Twitter::REST::Client.new do |config|
        ClientOptions.each do |k|
          config.__send__ k + ?=, *@config[k]
        end
      end
    end
  end
end

if __FILE__ == $0
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  c = TwitterClient::Client.new

  t = c.client.update "test tweet"
end
