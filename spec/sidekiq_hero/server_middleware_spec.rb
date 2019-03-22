# frozen_string_literal: true

RSpec.describe SidekiqHero::ServerMiddleware do
  let(:job) do
    {
      'class': 'SomeWorker',
      'jid': 'b4a577edbccf1d805744efa9',
      'args': [1, 'arg', true],
      'created_at': 123_456_789_0,
      'enqueued_at': 123_456_789_0
    }
  end
  let(:notifier) { instance_double('SidekiqHero::Notifier') }

  describe '#call' do
    before do
      allow(SidekiqHero.configuration).to receive(:notifier_server_message_class) { notifier }
    end

    context 'when job succeed' do
      context 'when does not exceed maximum time' do
        let(:expectation) do
          {
            status: 'success',
            started_at: Timecop.freeze(Time.new(2019, 1, 1, 10, 0, 0).utc),
            ended_at: Time.new(2019, 1, 1, 10, 0, 1).utc,
            total_time: 1
          }
        end

        before do
          allow(SidekiqHero.configuration).to receive(:exceed_maximum_time) { 2 }
          allow(notifier).to receive(:notify).with(job, expectation)
        end

        it 'does not notify' do
          described_class.new.call(nil, job, nil) { Timecop.travel(Time.new(2019, 1, 1, 10, 0, 1).utc) }

          expect(notifier).not_to have_received(:notify)
        end
      end

      context 'when exceed maximum time' do
        let(:expectation) do
          {
            status: 'success',
            started_at: Timecop.freeze(Time.new(2019, 1, 1, 10, 0, 0).utc),
            ended_at: Time.new(2019, 1, 1, 10, 0, 3).utc,
            total_time: 3
          }
        end
        let(:exceed_maximum_time) { 2 }

        before do
          allow(SidekiqHero.configuration).to receive(:exceed_maximum_time) { exceed_maximum_time }
          allow(notifier).to receive(:notify).with(job, expectation)
        end

        it 'prepares and compute the message for the notifier' do
          described_class.new.call(nil, job, nil) { Timecop.travel(Time.new(2019, 1, 1, 10, 0, 3).utc) }

          expect(notifier).to have_received(:notify).with(job, expectation)
        end
      end
    end

    context 'when exceed maximum time is not set' do
      let(:expectation) do
        {
          status: 'success',
          started_at: Timecop.freeze(Time.new(2019, 1, 1, 10, 0, 0).utc),
          ended_at: Time.new(2019, 1, 1, 10, 0, 1).utc,
          total_time: 1
        }
      end

      before do
        allow(notifier).to receive(:notify).with(job, expectation)
      end

      it 'always prepare and compute the message for the notifier' do
        described_class.new.call(nil, job, nil) { Timecop.travel(Time.new(2019, 1, 1, 10, 0, 1).utc) }

        expect(notifier).to have_received(:notify).with(job, expectation)
      end
    end

    context 'when job fail' do
      let(:expectation) do
        {
          status: 'failed',
          started_at: Timecop.freeze(Time.new(2019, 1, 1, 10, 0, 0).utc),
          ended_at: Time.new(2019, 1, 1, 10, 0, 1).utc,
          total_time: 1,
          error: RuntimeError.new('error').to_s
        }
      end

      before do
        allow_any_instance_of(described_class).to receive(:raise) { RuntimeError.new('error').to_s }
        allow(notifier).to receive(:notify).with(job, expectation)
      end

      it 'prepares and compute the error message for the notifier' do
        described_class.new.call(nil, job, nil) do
          Timecop.travel(Time.new(2019, 1, 1, 10, 0, 1).utc)
          raise 'error'
        end

        expect(notifier).to have_received(:notify).with(job, expectation)
      end
    end
  end
end
