# frozen_string_literal: true

module SidekiqHero
  class Configuration
    attr_accessor :notifier_class, :exceed_max_time, :queues

    def initialize
      @notifier_class = SidekiqHero::Notifier
      @queues = []
    end
  end
end
