# frozen_string_literal: true

RSpec.describe SidekiqHero::Notifier do
  let(:job) { { jid: '123', queue: 'standard' } }
  let(:meta_data) { { status: 'fail' } }

  describe '.notify' do
    let(:meta_data) { { status: 'fail' } }
    let(:notifier) { double('SidekiqHero::Notifier') }

    before do
      allow(described_class).to receive(:new) { notifier }
      allow(notifier).to receive(:notify).with(job, meta_data)
    end

    it 'calls `notify` on instance of self' do
      described_class.new.notify(job, meta_data)

      expect(notifier).to have_received(:notify).with(job, meta_data)
    end
  end

  describe '#notify' do
    let(:sidekiq) { double('Sidekiq') }

    before do
      allow(Sidekiq).to receive(:logger) { sidekiq }
      allow(sidekiq).to receive(:info).with("#{job} -- #{meta_data}")
    end

    it 'calls sidekiq logger STDOUT' do
      described_class.new.notify(job, meta_data)

      expect(sidekiq).to have_received(:info).with("#{job} -- #{meta_data}")
    end
  end
end
