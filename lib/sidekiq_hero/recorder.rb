# frozen_string_literal: true

module SidekiqHero
  class Recorder
    attr_reader :meta_data

    def initialize
      @meta_data = {}
    end

    def record(hash)
      meta_data.merge!(hash)
    end

    def record_elapsed_time
      total = meta_data.fetch(:ended_at, 0) - meta_data.fetch(:started_at, 0)
      record(total_time: total)
    end
  end
end

