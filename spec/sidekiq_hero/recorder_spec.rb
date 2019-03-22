# frozen_string_literal: true

RSpec.describe SidekiqHero::Recorder do
  describe '#record' do
    subject { described_class.new }

    it 'builds a hash by merging the hash argument' do
      expect(subject.meta_data).to be_empty

      subject.record(status: 'fail')

      expect(subject.meta_data).to eq(status: 'fail')
    end
  end

  describe '#record_elapsed_time' do
    subject do
      described_class.new.tap do |class_instance|
        class_instance.record(
          started_at: Time.new(2019, 1, 1, 10, 0, 0),
          ended_at: Time.new(2019, 1, 1, 10, 1, 0)
        )
      end
    end

    it 'computes total_time and merge it to meta_data' do
      expect(subject.record_elapsed_time[:total_time]).to eq 60.0
    end
  end
end
