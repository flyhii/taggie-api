# frozen_string_literal: true

require 'figaro'
require 'logger'
require 'rack/session'
require 'roda'
require 'sequel'
require 'rack/cache'
require 'redis-rack-cache'
require 'yaml'

module FlyHii
  # Environment-specific configuration
  class App < Roda
    plugin :environments

    # Environment variables setup
    Figaro.application = Figaro::Application.new(
      environment:,
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load
    def self.config = Figaro.env

    use Rack::Session::Cookie, secret: config.SESSION_SECRET

    # Setup Cacheing mechanism
    configure :development do
      use Rack::Cache,
          verbose: true,
          metastore: 'file:_cache/rack/meta',
          entitystore: 'file:_cache/rack/body'
    end

    configure :production do
      puts 'RUNNING IN PRODUCTION MODE'
      # Set DATABASE_URL environment variable on production platform

      use Rack::Cache,
          verbose: true,
          metastore: "#{config.REDIS_URL}/0/metastore",
          entitystore: "#{config.REDIS_URL}/0/entitystore"
    end

    # Automated HTTP stubbing for testing only
    configure :app_test do
      require_relative '../spec/helpers/vcr_helper'
      VcrHelper.setup_vcr
      VcrHelper.configure_vcr_for_instagram(recording: :none)
    end

    # Database Setup (ensure DATABASE_URL already configured on production)
    configure :development, :test, :app_test do
      require 'pry'; # for breakpoints
      ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
    end

    # Database Setup
    @db = Sequel.connect(ENV.fetch('DATABASE_URL'))
    def self.db = @db # rubocop:disable Style/TrivialAccessors

    # Logger Setup
    @logger = Logger.new($stderr)
    def self.logger = @logger # rubocop:disable Style/TrivialAccessors
  end
end
