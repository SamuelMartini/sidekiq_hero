# frozen_string_literal: true

RSpec.describe SidekiqHero::Configuration do
  describe '#initialize' do
    subject { described_class.new }

    it 'assignes default configuration' do
      expect(subject.notifier_server_message_class).to be_kind_of SidekiqHero::Notifier
      expect(subject.exceed_maximum_time).to eq 0
    end
  end
end
