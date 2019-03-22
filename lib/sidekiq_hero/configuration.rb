# frozen_string_literal: true

module SidekiqHero
  class Configuration
    attr_accessor :notifier_server_message_class, :exceed_maximum_time

    def initialize
      @notifier_server_message_class = SidekiqHero::Notifier.new
      @exceed_maximum_time = 0
    end
  end
end

