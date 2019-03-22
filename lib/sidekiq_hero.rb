# frozen_string_literal: true

require 'sidekiq_hero/version'
require 'sidekiq/api'
require 'sidekiq_hero/configuration'
require 'sidekiq_hero/notifier'

module SidekiqHero
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
