# frozen_string_literal: true

RSpec.describe SidekiqHero::NotifierWrapper do
  let(:notifier) { instance_double('SidekiqHero::Notifier') }
  let(:notifier_class) { double('notifier_class') }
  let(:meta_data) { { status: 'success'} }
  let(:queue) { 'default' }

  before do
    allow(notifier_class).to receive(:new) { notifier }
    allow(notifier).to receive(:notify).with(job, meta_data)
    SidekiqHero.configure do |config|
      config.notifier_class = notifier_class
      config.queues = [queue]
    end
  end

  describe '#call' do
    before { SidekiqHero::NotifierWrapper.new(job: job, meta_data: meta_data).call }

    context 'when the job is flagged for monitor' do
      let(:job) { { sidekiq_hero_monitor: true } }

      it 'notifies the worker meta_data' do
        expect(notifier).to have_received(:notify).with(job, meta_data)
      end
    end

    context 'when the job is NOT flagged for monitor' do
      let(:job) { { sidekiq_hero_monitor: false } }

      it 'notifies the worker meta_data' do
        expect(notifier).not_to have_received(:notify).with(job, meta_data)
      end
    end

    context 'when worker queue does not belong to configured queue' do
      before do
        allow(SidekiqHero.configuration).to receive(:queues) { queue }
      end

      context 'with sidekiq_hero_monitor to false' do
        let(:job) { { queue: 'not_matching', sidekiq_hero_monitor: false } }

        it 'does not notify' do
          expect(notifier).not_to have_received(:notify).with(job, meta_data)
        end
      end

      context 'with sidekiq_hero_monitor to true' do
        let(:job) { { queue: queue, sidekiq_hero_monitor: true } }

        it 'gives priority to sidekiq_hero_monitor calling the notifier' do
          expect(notifier).to have_received(:notify).with(job, meta_data)
        end
      end
    end

    context 'when worker queue belongs to configured queue' do
      let(:queue) { 'match' }

      context 'with sidekiq_hero_monitor to false' do
        let(:job) { { queue: queue, sidekiq_hero_monitor: false } }

        it 'notifies' do
          expect(notifier).to have_received(:notify).with(job, meta_data)
        end
      end
    end

    context 'when worker exceed monitor time' do
      let(:meta_data) { { status: 'success', total_time: 2 } }
      let(:job) { { sidekiq_hero_monitor_time: 1 } }

      it 'notifies the worker data' do
        expect(notifier).to have_received(:notify).with(job, meta_data.merge(worker_time_out: true))
      end
    end

    context 'when worker does not exceed monitor time' do
      let(:meta_data) { { status: 'success', total_time: 1 } }
      let(:job) { { sidekiq_hero_monitor_time: 2 } }

      it 'does not notify the worker data' do
        expect(notifier).not_to have_received(:notify).with(job, meta_data.merge(worker_time_out: true))
      end
    end
  end
end
