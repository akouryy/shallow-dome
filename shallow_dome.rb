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

t = nil
while gets
  if $_.chomp.empty?
    t = nil
  else
    t = c.tweet $_.encode("utf-8"), retry_with_space: true, reply: t
  end
end
