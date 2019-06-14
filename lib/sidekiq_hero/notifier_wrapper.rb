# frozen_string_literal: true

module SidekiqHero
  class NotifierWrapper
    attr_reader :job, :meta_data, :notifier, :queues

    def initialize(job: nil, meta_data: nil)
      @job = job
      @meta_data = meta_data
      @notifier = SidekiqHero.configuration.notifier_class.new
      @queues = SidekiqHero.configuration.queues
    end

    def call
      return unless monitor_this_worker?

      meta_data[:worker_time_out] = exceeded_max_time?

      notifier.notify(job, meta_data)
    end

    private

    def monitor_this_worker?
      sidekiq_hero_monitor || monitor_queue? || exceeded_max_time?
    end

    def exceeded_max_time?
      return false if sidekiq_hero_monitor_time.nil?

      meta_data[:total_time] > sidekiq_hero_monitor_time
    end

    def sidekiq_hero_monitor_time
      job['sidekiq_hero_monitor_time']
    end

    def sidekiq_hero_monitor
      job['sidekiq_hero_monitor']
    end

    def monitor_queue?
      queues.include?(job['queue'])
    end
  end
end
