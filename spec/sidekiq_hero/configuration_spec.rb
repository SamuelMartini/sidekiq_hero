# frozen_string_literal: true

RSpec.describe SidekiqHero::Configuration do
  describe '#initialize' do
    subject { described_class.new }

    it 'assignes default configuration' do
      expect(subject.notifier_class).to eq SidekiqHero::Notifier
      expect(subject.queues).to be_empty
    end
  end
end
