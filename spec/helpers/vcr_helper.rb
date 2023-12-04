# frozen_string_literal: true

require 'vcr'
require 'webmock'

# Setting up VCR
module VcrHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'
  INSTAGRAM_CASSETTE = 'instagram_api'

  def self.setup_vcr
    VCR.configure do |config|
      config.cassette_library_dir = CASSETTES_FOLDER
      config.hook_into :webmock
    end
  end

  # Unavoidable :reek:TooManyStatements for VCR configuration
  def self.configure_vcr_for_instagram(recording: :new_episodes)
    VCR.configure do |config|
      config.filter_sensitive_data('<INSTAGRAM_TOKEN>') { INSTAGRAM_TOKEN }
      config.filter_sensitive_data('<INSTAGRAM_TOKEN_ESC>') { CGI.escape(INSTAGRAM_TOKEN) }
    end

    VCR.insert_cassette(
      INSTAGRAM_CASSETTE,
      record: recording,
      match_requests_on: %i[method uri headers]
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
