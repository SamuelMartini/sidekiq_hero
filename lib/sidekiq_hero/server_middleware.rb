# frozen_string_literal: true

module SidekiqHero
  class ServerMiddleware
    def call(_worker, job, _queue)
      recorder.record(status: 'passed', started_at: Time.now.utc.round)
      yield
      recorder.record(status: 'success')
    rescue => e
      recorder.record(status: 'failed', error: e.to_s)
      raise e
    ensure
      recorder.record(ended_at: Time.now.utc.round)
      recorder.record_elapsed_time
      notifier.notify(job, recorder.meta_data) if exceeded_maximum_time? || job_failed?
    end

    private

    def recorder
      @recorder ||= SidekiqHero::Recorder.new
    end

    def server_message_class
      @server_message_class ||= SidekiqHero.configuration.server_message_class
    end

    def meta_data
      @meta_data ||= {}
    end

    def notifier
      SidekiqHero.configuration.notifier_server_message_class
    end

    def exceed_maximum_time
      @exceed_maximum_time ||= SidekiqHero.configuration.exceed_maximum_time
    end

    def exceeded_maximum_time?
      recorder.meta_data[:total_time] > exceed_maximum_time
    end

    def job_failed?
      recorder.meta_data[:status] == 'failed'
    end
  end
end
