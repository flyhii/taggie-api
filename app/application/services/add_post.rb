# frozen_string_literal: true

require 'dry/transaction'

module FlyHii
  module Service
    # Transaction to store post from Instagram API to database
    class AddPost
      include Dry::Transaction

      step :find_hashtag_name
      step :store_post

      private

      DB_ERR_MSG = 'Having trouble accessing the database'
      IG_NOT_FOUND_MSG = 'Could not find that post on Instagram'

      def find_hashtag_name(input)
        if (post = post_in_database(input))
          input[:local_post] = post
        else
          input[:remote_post] = post_from_instagram(input)
        end
        Success(input)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
      end

      def store_post(input)
        post =
          if (new_po = input[:remote_post])
            Repository::For.entity(new_po).create(new_po)
          else
            input[:local_post]
          end
        Success(Response::ApiResult.new(status: :created, message: post))
      rescue StandardError
        # App.logger.error("ERROR: #{e.inspect}")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # Support methods for steps

      def post_from_instagram(input)
        FlyHii::Instagram::MediaMapper
          .new(App.config.INSTAGRAM_TOKEN, App.config.ACCOUNT_ID)
          .find(input)
      rescue StandardError
        raise IG_NOT_FOUND_MSG
      end

      def post_in_database(input)
        Repository::For.klass(Entity::Post)
          .find_full_name(input)
      end
    end
  end
end
