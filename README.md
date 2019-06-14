# SidekiqHero

Sidekiq middleware that fire a notification when a flagged worker has ended its job, successful or not.
A worker can be flagged to always fire a notification or to fire it only when the process exceed a configured time.

The default notifier just log on sidekiq server. You can configure your notification class which will receive all the metadata the job has recorder i.e. exceeded_max_time, failed.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq_hero'
```

And then execute:

    $ bundle install


## Usage

In your rails application include the middleware. [What is a middleware?](https://github.com/mperham/sidekiq/wiki/Middleware)

```ruby
# config/initializers/sidekiq.rb

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add SidekiqHero::ServerMiddleware
  end
end

SidekiqHero.configure do |config|
  config.notifier_class = YourNotifier
  config.queues = ['queue1', 'queue2']
end
```
You can pass your sidekiq_hero configuration via `sidekiq_options`. SidekiqHero will look for `sidekiq_hero_monitor_time` and `sidekiq_hero_monitor`.

```ruby
class HardWorker
  include Sidekiq::Worker

  sidekiq_options sidekiq_hero_monitor_time: 5

  def perform(*)
  end
end
```

`@sidekiq_hero_monitor`
boolean value to flag a single worker to be monitored. This worker will always trigger a notification when the job is done, successful or not.

`@sidekiq_hero_monitor_time`
is the time in seconds within the job is considered ok. If the job takes more than this time the notifier is triggered. The meta_data will contains `total_time` and `worker_time_out` which can be true or false.

In SidekiqHero.configure:
`@notifier_class`
is where you can add your custom class responsible to notify the job message.
The default class of sidekiq_hero just log to STDOUT so you need to implement a class that respond to `.notify`
and takes two arguments: job, meta_data

`@queues`
you can flag a whole queue to be monitored.


`sidekiq_hero_monitor` always takes precendece over other configuration.

Sidekiq will look first to `sidekiq_hero_monitor`, then to the `queues` and finally `sidekiq_hero_monitor_time`. Note that the execution time is always recorded and passed via meta_data to the configured notifier.

```ruby
class DummyNotifier
  def self.notify(job, meta_data)
    new.notify(job, meta_data)
  end

  # job { 'class': 'SomeWorker', 'jid': 'b4a577edbccf1d805744efa9', 'args': [1, 'arg', true], 'created_at': 123_456_789_0, 'enqueued_at': 123_456_789_0 }
  # meta_data { status: 'success', total_time: 1, worker_time_out: false}
  def notify(job, meta_data)
    send_email if meta_data[:status] == 'success'
    request_help if meta_data[:status] == 'failed'
    notify_slack(total_time) if meta_data[:worker_time_out]
  end
end
```


## Development

After checking out the repo run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SamuelMartini/sidekiq_hero

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
