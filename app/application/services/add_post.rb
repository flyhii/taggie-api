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
      RECENT_IG_NOT_FOUND_MSG = 'Could not find that recent post on Instagram'

      def find_hashtag_name(input)
        puts input[:hashtag_name]
        input[:Instagram_posts] = post_from_instagram(input[:hashtag_name])

        Success(input)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
      end

      def store_post(input)
        puts '9'
        new_po = input[:Instagram_posts]
        puts new_po

        puts post = new_po.map do |new_post|
          Repository::For.entity(new_post).create(new_post)
        end
        Success(Response::ApiResult.new(status: :created, message: post))
      rescue StandardError
        # App.logger.error("ERROR: #{e.inspect}")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # Support methods for steps

      def post_from_instagram(input)
        puts '66'
        puts input
        FlyHii::Instagram::MediaMapper
          .new(App.config.INSTAGRAM_TOKEN, App.config.ACCOUNT_ID)
          .find(input)
      rescue StandardError
        raise IG_NOT_FOUND_MSG
      end

      def recent_post_from_instagram(input)
        puts 'recent66'
        FlyHii::Instagram::RecentMediaMapper
          .new(App.config.INSTAGRAM_TOKEN, App.config.ACCOUNT_ID)
          .find(input)
      rescue StandardError
        raise RECENT_IG_NOT_FOUND_MSG
      end

      # def post_in_database(input)
      #   Repository::For.klass(Entity::Post)
      #     .find_full_name(input)
      # end
    end
  end
end
