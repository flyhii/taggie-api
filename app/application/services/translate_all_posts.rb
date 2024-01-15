# frozen_string_literal: true

require 'dry/transaction'

module FlyHii
  module Service
    # Retrieves array of all listed post entities
    class TranslateAllPosts
      include Dry::Transaction

      step :translate_posts
      step :store_post

      private

      TR_ERR = 'Translate error'
      DB_ERR_MSG = 'Cannot access database'
      GOOGLE_NOT_FOUND_MSG = 'Could not translate that post on Google'
      PROCESSING_MSG = 'Processing the summary request'
      WORKER_ERR = 'Cannot process worker'

      def validate_language(input)
        list_request = input[:list_request].call
        if list_request.success?
          Success(input.merge(list: list_request.value!))
        else
          Failure(list_request.failure)
        end
      end

      def request_translate_worker(input)
        puts 'inside worker'
        Messaging::Queue.new(App.config.TRANSLATE_QUEUE_URL, App.config).send(message)
        Failure(Response::ApiResult.new(status: :processing,
                                        message: { request_id: input[:request_id], msg: PROCESSING_MSG }))
        # Messaging::Queue
        #   .new(App.config.TRANSLATE_QUEUE_URL, App.config)
        #   .send(Representer::Post.new(input[:trans_caption]).to_json)

        # Failure(Response::ApiResult.new(status: :processing, message: PROCESSING_MSG))
      rescue StandardError
        # log_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: WORKER_ERR))
      end

      def translate_posts(input)
        puts 'google translate'
        # puts input
        all_posts = post_in_database
        puts input[:trans_captions] = translate_posts_from_google(input[:target_language], all_posts)
        Success(input)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
      end

      def store_post(input)
        puts 'store'
        Repository::Translation.create(input[:trans_captions])
        Repository::For.klass(Entity::Post).find_full_name
          .then { |posts| Entity::PostsList.new(posts) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
        # Success(post)
      rescue StandardError
        # App.logger.error("ERROR: #{e.inspect}")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      def translate_posts_from_google(input, all_posts) # rubocop:disable Metrics/AbcSize
        puts '99'
        all_posts.to_h do |post|
          puts post[:caption]
          #   po = post[:caption].split("\n")
          translated_caption = GoogleTranslate::TransTextMapper
            .new(App.config.GOOGLE_PROJECT_ID)
            .translate(input, post[:caption].to_json)
          [post[:remote_id], JSON.parse(translated_caption)['data']['translations'][0]['translatedText']]
        end
      rescue StandardError
        raise GOOGLE_NOT_FOUND_MSG
      end

      def post_in_database
        Repository::For.klass(Entity::Post).find_full_name
      end
    end
  end
end
