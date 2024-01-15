# frozen_string_literal: true

require_relative '../require_app'
require_relative 'translatetext_monitor'
require_relative 'job_reporter'
require_app

require 'figaro'
require 'shoryuken'

module TranslateText
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
    shoryuken_options queue: config.TRANSLATE_QUEUE_URL, auto_delete: true

    def perform(_sqs_msg, request)
      job = JobReporter.new(request, Worker.config.GOOGLE_TOKEN)

      # doamin contributions/repositories
      # def translate_locally
      job.report(TranslateTextMonitor.starting_percent)

      result = FlyHii::GoogleTranslate::TransTextMapper.new(job.token).translate('fr', 'how are you')
      puts result
      job.report_each_second(2) { TranslateTextMonitor.mapper_done }
      # FlyHii::Repository.entity(result).create(result)

      # FlyHii::TranslateRepo.new(job.project, Worker.config).translate_locally do |line|
      #   job.report TranslateTextMonitor.progress(line)
      # end

      # Keep sending finished status to any latecoming subscribers
      job.report_each_second(5) { TranslateTextMonitor.finished_percent }
    rescue FlyHii::TranslateRepo::Errors::NoTranslateTextFound
      # NoTranslateTextFound also in contributions/repositories
      # worker should crash fail early - only catch errors we expect!
      puts 'ALREADY TRAANSLATED -- ignoring request'
    end
  end
end
