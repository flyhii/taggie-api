# frozen_string_literal: true

require_relative '../require_app'
require_app

require 'figaro'
require 'shoryuken'

# Shoryuken worker class to call api and get different type of posts in parallel
class APIPostWorker
  # Environment variables setup
  Figaro.application = Figaro::Application.new(
    environment: ENV['RACK_ENV'] || 'development',
    path: File.expand_path('config/secrets.yml')
  )
  Figaro.load
  def self.config() = Figaro.env

  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: config.AWS_ACCESS_KEY_ID,
    secret_access_key: config.AWS_SECRET_ACCESS_KEY,
    region: config.AWS_REGION
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.CLONE_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, request)
    posts = FlyHii::Representer::Post
      .new(OpenStruct.new).from_json(request)
    FlyHii::Post.new(posts)
    # FlyHii::Post.new(posts).clone
  rescue FlyHii::Post::Errors::NoMediaFound
    puts 'POSTS EXISTS -- ignoring request'
  end
end
