# frozen_string_literal: true

RSpec.describe SidekiqHero do
  describe '.configuration' do
    it 'returns an instance of Configuration' do
      expect(described_class.configuration).to be_kind_of(SidekiqHero::Configuration)
    end
  end
end
