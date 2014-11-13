# encoding utf-8

require 'bundler'
Bundler.require

require './lib/browser'
require './lib/config_class_generator'
require './lib/symbol_plus'

require './bin/client'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
ShallowDome::ConfigManager.load_configs

c = ShallowDome::Client.new

t = c.tweet "test"
