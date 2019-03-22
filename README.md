# SidekiqHero

Sidekiq middleware that notify a recipient when a job fail or takes a configurable excessive time to process.
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
  config.notifier_server_message_class = YourNotifier.new
  config.exceed_maximum_time = time_in_seconds
end
```
`@notifier_server_message_class` is where you can add an instance of a class responsible to notify the job message.
The default class of sidekiq_hero just log to STDOUT so you need to implement a class that respond to `.notify`
and takes two arguments: job, meta_data

`exceed_maximum_time` is the time in seconds within which the job is conidered ok. If the job takes more than @exceed_maximum_time the notifier is triggered

```ruby

class DummyNotifier
  def self.notify(job, meta_data)
    new.notify(job, meta_data)
  end

  # job { 'class': 'SomeWorker', 'jid': 'b4a577edbccf1d805744efa9', 'args': [1, 'arg', true], 'created_at': 123_456_789_0, 'enqueued_at': 123_456_789_0 }
  # meta_data { status: 'success', started_at: Timecop.freeze(Time.new(2019, 1, 1, 10, 0, 0).utc), ended_at: Time.new(2019, 1, 1, 10, 0, 1).utc, total_time: 1 }
  def notify(job, meta_data)
    # your code to notify e.g. slack, email, logger
  end
end
```

    
## Development

After checking out the repo run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SamuelMartini/sidekiq_hero

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
