# frozen_string_literal: true

module SidekiqHero
  class Notifier

    def notify(job, meta_data)
      Sidekiq.logger.info "#{job} -- #{meta_data}"
    end
  end
end

