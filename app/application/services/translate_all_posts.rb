# frozen_string_literal: true

require 'dry/transaction'

module FlyHii
  module Service
    # Retrieves array of all listed post entities
    class TranslateAllPosts
      include Dry::Transaction

      # step :validate_language
      # step :translate_posts
      # step :store_post
      # worker stuff
      step :translate_posts
      step :ask_translate_worker
      step :store_post
    # step :retrieve_post

      private

      TR_ERR = 'Translate error'
      DB_ERR_MSG = 'Cannot access database'
      GOOGLE_NOT_FOUND_MSG = 'Could not translate that post on Google'
      PROCESSING_MSG = 'Processing the summary request'
      WORKER_ERR = 'Cannot process worker'
      CANT_ACCESS_WORKER_MSG = 'Cannot process into worker'

      def validate_language(input)
        list_request = input[:list_request].call
        if list_request.success?
          Success(input.merge(list: list_request.value!))
        else
          Failure(list_request.failure)
        end
      end

      def translate_posts(input)
        puts 'google translate'
        # puts input
        # all_posts = post_in_database
        # puts input[:translated_captions] = translate_posts_from_google(input[:target_language], all_posts)
        # Success(input)
        # worker stuff
        all_posts = post_in_database
        translated_posts = translate_posts_from_google(input[:target_language], all_posts)
        Success(translated_posts)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
      end

      def ask_translate_worker(input)
        puts 'in service ask worker'
        puts input
        # Messaging::Queue.new(App.config.TRANSLATE_QUEUE_URL, App.config).send(translate_request_json(input))
        Messaging::Queue.new(App.config.TRANSLATE_QUEUE_URL, App.config).send(input.to_json)
        Failure(Response::ApiResult.new(status: :processing,
                                        message: { request_id: input[:request_id], msg: PROCESSING_MSG }))
      rescue StandardError => e
        log_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: WORKER_ERR))
      end

      def store_post
        puts 'store'
        # worker stuff
        # comment out Repository::Translation.create(input[:translated_captions])
        # Repository::Translation.create(input[:translated_captions])
        Repository::For.klass(Entity::Post).find_full_name
          .then { |posts| Entity::PostsList.new(posts) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
        # Success(post)
      rescue StandardError
        # App.logger.error("ERROR: #{e.inspect}")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      def translate_posts_from_google(input, all_posts)
        puts '99'
        # worker stuff
        google_project_id = App.config.GOOGLE_TOKEN
        json_map = all_posts.map do |post|
          puts 'queue working'
          json = {
            google_pj_id: google_project_id,
            target_language: input,
            post_id: post[:remote_id],
            all_posts: post[:caption]
          }.to_json
          puts json
          json
        end
        puts "json: #{json_map}"
        json_map
        #   all_posts.to_h do |post|
        #   puts post[:caption]
        #   translated_caption = GoogleTranslate::TransTextMapper
        #     .new(App.config.GOOGLE_TOKEN)
        #     .translate(input, post[:caption])
        #   [post[:remote_id], JSON.parse(translated_caption)['data']['translations'][0]['translatedText']]
        # end
      rescue StandardError
        raise GOOGLE_NOT_FOUND_MSG
      end

      def log_error(error)
        App.logger.error [error.inspect, error.backtrace].flatten.join("\n")
      end

      def translate_request_json(input)
        Response::TranslateRequest.new(input[:caption], input[:request_id])
          .then { Representer::TranslateRequest.new(_1) }
          .then(&:to_json)
      end

      def post_in_database
        Repository::For.klass(Entity::Post).find_full_name
      end
    end
  end
end
