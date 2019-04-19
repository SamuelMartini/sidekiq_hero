# frozen_string_literal: true

RSpec.describe SidekiqHero::ServerMiddleware do
  let(:job) { 'test' }
  let(:recorder) { instance_double('SidekiqHero::Recorder') }
  let(:meta_data_test) { { meta_data: 'test' } }
  let(:notifier) { double('notifier') }
  let(:error_message) { RuntimeError.new('error') }

  describe '#call' do
    before do
      allow_any_instance_of(described_class).to receive(:raise) { error_message }
      allow(SidekiqHero::Recorder).to receive(:new) { recorder }
      allow(recorder).to receive(:worker_passed)
      allow(recorder).to receive(:worker_succeeded)
      allow(recorder).to receive(:worker_failed).with(RuntimeError)
      allow(recorder).to receive(:worker_ended)
      allow(recorder).to receive(:elapsed_time)
      allow(recorder).to receive(:meta_data) { meta_data_test }
      allow(SidekiqHero::NotifierWrapper).to receive(:new).with(job: job, meta_data: meta_data_test) { notifier }
      allow(notifier).to receive(:call)
    end

    context 'when job succeed' do
      subject { described_class.new.call(nil, job, nil) { true } }

      it 'calls all the messages on recorder' do
        subject

        expect(recorder).to have_received(:worker_passed)
        expect(recorder).to have_received(:worker_succeeded)
        expect(recorder).to have_received(:worker_ended)
        expect(recorder).to have_received(:elapsed_time)
        expect(recorder).to have_received(:meta_data)
        expect(SidekiqHero::NotifierWrapper).to have_received(:new).with(job: job, meta_data: meta_data_test)
        expect(notifier).to have_received(:call)
      end

      it 'does not call work failed' do
        subject

        expect(recorder).not_to have_received(:worker_failed)
      end
    end

    context 'when job fails' do
      subject { described_class.new.call(nil, job, nil) { raise error_message } }

      it 'calls all the messages on recorder' do
        subject

        expect(recorder).to have_received(:worker_passed)
        expect(recorder).to have_received(:worker_failed).with(error_message)
        expect(recorder).to have_received(:worker_ended)
        expect(recorder).to have_received(:elapsed_time)
        expect(recorder).to have_received(:meta_data)
        expect(SidekiqHero::NotifierWrapper).to have_received(:new).with(job: job, meta_data: meta_data_test)
        expect(notifier).to have_received(:call)
      end

      it 'does not call work succeeded' do
        subject

        expect(recorder).not_to have_received(:worker_succeeded)
      end
    end
  end
end
