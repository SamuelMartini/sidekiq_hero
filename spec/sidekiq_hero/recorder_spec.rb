# frozen_string_literal: true

RSpec.describe SidekiqHero::Recorder do
  let(:started_at) { Time.new(2019, 1, 1, 10, 0, 0).utc }
  let(:ended_at) { Time.new(2019, 1, 1, 10, 0, 1).utc }

  subject { described_class.new }

  describe '#elapsed_time' do
    subject do
      described_class.new.tap do |recorder|
        recorder.send(:record, started_at: started_at, ended_at: ended_at)
      end
    end

    it 'computes total time' do
      expect { subject.elapsed_time }.to change { subject.meta_data[:total_time] }.from(nil).to(ended_at - started_at)
    end
  end

  describe '#worker_passed' do
    it 'records status' do
      expect { subject.worker_passed }.to change { subject.meta_data[:status] }.from(nil).to('passed')
    end

    it 'records time' do
      expect { subject.worker_passed }.to change { subject.meta_data[:started_at] }.from(nil)
    end
  end

  describe '#worker_succeeded' do
    it 'records status' do
      expect { subject.worker_succeeded }.to change { subject.meta_data[:status] }.from(nil).to('success')
    end
  end

  describe '#worker_failed' do
    it 'records status' do
      expect { subject.worker_failed('fail') }.to change { subject.meta_data[:status] }.from(nil).to('failed')
    end

    it 'records error message' do
      expect { subject.worker_failed('fail') }.to change { subject.meta_data[:error] }.from(nil).to('fail')
    end
  end

  describe '#worker_ended' do
    it 'records time' do
      expect { subject.worker_ended }.to change { subject.meta_data[:ended_at] }.from(nil)
    end
  end
end
