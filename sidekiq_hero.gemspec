lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq_hero/version'

Gem::Specification.new do |spec|
  spec.name          = 'sidekiq_hero'
  spec.version       = SidekiqHero::VERSION
  spec.authors       = ['Samuel Martini']
  spec.email         = ['samuelmartini@nebulab.it']

  spec.summary       = %q{Sidekiq Middleware for job notification}
  spec.description   = <<-TEXT
    Sidekiq middleware that fire a notification when a flagged worker has ended its job, successful or not.
  TEXT
  spec.homepage      = 'https://github.com/SamuelMartini/sidekiq_hero'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|dummy_app)/})
  end
  spec.require_paths = ['lib']

  spec.add_dependency             'sidekiq', '>= 3.0'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'timecop'
end
