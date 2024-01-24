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

    include Shoryuken::Worker
    Shoryuken.sqs_client_receive_message_opts = { wait_time_seconds: 10 }
    shoryuken_options queue: config.TRANSLATE_QUEUE_URL, auto_delete: true

    def perform(_sqs_msg, request)
      job = JobReporter.new(request, Worker.config)
      puts 'in perform'

      job.report_each_second(2) { TranslateTextMonitor.starting_percent }
      translation_mapper_worker(request)
      # puts store_post_worker(result)
      job.report_each_second(2) { TranslateTextMonitor.mapper_done }

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
      # puts data_hash
      translated_captions = data_hash.map do |post|
        puts 'translation_mapper_worker working'
        input_hash = JSON.parse(post)
        google_pj_id = input_hash['google_pj_id']
        target_language = input_hash['target_language']
        remote_id = input_hash['post_id']
        all_posts = input_hash['all_posts']
        translated_caption = FlyHii::GoogleTranslate::TransTextMapper
          .new(google_pj_id)
          .translate(target_language, all_posts.to_json)
        # puts "translated_caption: #{translated_caption}"
        translate_text = JSON.parse(translated_caption)['data']['translations'][0]['translatedText']
        # puts "translate_text: #{translate_text}"
        translated_caption_storage = {
          remote_id => translate_text
        }
        # puts "translated_caption_storage: #{translated_caption_storage}"
        store_post_worker(translated_caption_storage)
      end
    end

    def store_post_worker(input)
      puts 'in store_post_worker'
      FlyHii::Repository::Translation.create(input)
    end
  end
end
