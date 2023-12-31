# frozen_string_literal: true

require_relative '../require_app'
require_relative 'showpost_monitor'
require_relative 'job_reporter'
require_app

require 'figaro'
require 'shoryuken'

class ShowPost
  # Shoryuken worker class to call api in parallel
  class Worker
    # Environment variables setup
    Figaro.application = Figaro::Application.new(
      environment: ENV['RACK_ENV'] || 'development',
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load
    def self.config = Figaro.env

    Shoryuken.sqs_client = Aws::SQS::Client.new(
      access_key_id: config.AWS_ACCESS_KEY_ID,
      secret_access_key: config.AWS_SECRET_ACCESS_KEY,
      region: config.AWS_REGION
    )

    include Shoryuken::Worker
    Shoryuken.sqs_client_receive_message_opts = { wait_time_seconds: 10 }
    shoryuken_options queue: config.CLONE_QUEUE_URL, auto_delete: true

    def perform(_sqs_msg, request)
      job = JobReporter.new(request, Worker.config)

      job.report(ShowPostMonitor.starting_percent)
      FlyHii::Post.new(job.project, Worker.config).clone_locally do |line|
        job.report ShowPostMonitor.progress(line)
      end

      # Keep sending finished status to any latecoming subscribers
      job.report_each_second(5) { ShowPostMonitor.finished_percent }
    rescue FlyHii::Post::Errors::NoMediaFound
      # worker should crash fail early - only catch errors we expect!
      puts 'POSTS EXISTS -- ignoring request'
    end
  end
end
