# encoding utf-8

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
        set_classes
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

    Space = "\u200c".freeze

    def initialize
      @client = Twitter::REST::Client.new (ConfigClassGenerator.get_one :oauth)
    end

    def tweet message, reply: nil, retry_times: 0, retry_with_space: false
      retry_count = 0
      begin
        @client.update! message, in_reply_to_status: reply
      rescue Twitter::Error::DuplicateStatus
        retry_count += 1
        if retry_count <= retry_times
          retry
        elsif retry_with_space
          retry_count = 0
          message += Space
          retry
        else
          raise
        end
      end
    end
  end
end
