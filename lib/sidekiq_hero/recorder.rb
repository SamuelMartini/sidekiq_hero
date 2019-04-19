# frozen_string_literal: true

module SidekiqHero
  class Recorder
    attr_reader :meta_data

    def initialize
      @meta_data = {}
    end

    def elapsed_time
      total = meta_data.fetch(:ended_at, 0) - meta_data.fetch(:started_at, 0)
      record(total_time: total)
    end

    def worker_passed
      record(status: 'passed', started_at: Time.now.utc.round)
    end

    def worker_succeeded
      record(status: 'success')
    end

    def worker_failed(error)
      record(status: 'failed', error: error.to_s)
    end

    def worker_ended
      record(ended_at: Time.now.utc.round)
    end

    private

    def record(hash)
      meta_data.merge!(hash)
    end
  end
end

