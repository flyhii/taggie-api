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
    puts 'translate worker START'
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

    @google_pj_id2 = config.GOOGLE_PROJECT_ID
    puts @google_pj_id2

    include Shoryuken::Worker
    Shoryuken.sqs_client_receive_message_opts = { wait_time_seconds: 10 }
    shoryuken_options queue: config.TRANSLATE_QUEUE_URL, auto_delete: true

    def perform(_sqs_msg, request)
      job = JobReporter.new(request, Worker.config)
      puts 'in perform'

      # def translate_locally
      job.report_each_second(2) { TranslateTextMonitor.starting_percent }
      result = translation_mapper_worker(request)
      puts "result: #{result}"
      # translated_storage = store_post_worker(result)
      job.report_each_second(2) { TranslateTextMonitor.mapper_done }
      # FlyHii::Repository.entity(result).create(result)

      # FlyHii::TranslateRepo.new(job.project, Worker.config).translate_locally do |line|
      #   job.report TranslateTextMonitor.progress(line)
      # end

      # Keep sending finished status to any latecoming subscribers
      job.report_each_second(5) { TranslateTextMonitor.finished_percent }
    rescue FlyHii::TranslateRepo::Errors::NoTranslateTextFound
      # worker should crash fail early - only catch errors we expect!
      puts 'ALREADY TRAANSLATED -- ignoring request'
    end

    def translation_mapper_worker(input)
      puts 'in translation worker'
      puts "in worker #{input}"
      data_hash = JSON.parse(input)
      google_pj_id = data_hash['google_pj_id']
      target_language = data_hash['target_language']
      # remote_id = data_hash['remote_id']
      all_posts = data_hash['all_posts']
      translated_caption = FlyHii::GoogleTranslate::TransTextMapper
        .new(google_pj_id)
        .translate(target_language, all_posts.to_json)
      puts translated_caption
      # translated_caption_storage = {
      #   'remote_id'          => remote_id,
      #   'translated_caption' => translated_caption
      # }
      # puts translated_caption_storage
        # [post[:remote_id], JSON.parse(translated_caption)['data']['translations'][0]['translatedText']]
        # Repository::Translation.create(input[:translated_captions])
    end

    def store_post_worker(input)
      # Repository::Translation.create(input[:translated_captions])
    end
  end
end
