# frozen_string_literal: true

module SidekiqHero
  class ServerMiddleware
    attr_reader :recorder

    def initialize
      @recorder = SidekiqHero::Recorder.new
    end

    def call(_worker, job, _queue)
      recorder.worker_passed
      yield
      recorder.worker_succeeded
    rescue => e
      recorder.worker_failed(e)

      raise e
    ensure
      recorder.worker_ended
      recorder.elapsed_time
      NotifierWrapper.new(job: job, meta_data: recorder.meta_data).call
    end
  end
end
