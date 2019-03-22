# frozen_string_literal: true

module SidekiqHero
  class Notifier

    def self.notify(job, meta_data)
      new.notify(job, meta_data)
    end

    def notify(job, meta_data)
      Sidekiq.logger.info "#{job} -- #{meta_data}"
    end
  end
end

