# frozen_string_literal: true

require 'dry/transaction'

module FlyHii
  module Service
    # Transaction to store post from Instagram API to database
    class AddRecentPost
      include Dry::Transaction

      step :find_hashtag_name
      step :store_post

      private

      DB_ERR_MSG = 'Having trouble accessing the database'
      RECENT_IG_NOT_FOUND_MSG = 'Could not find that recent post on Instagram'

      def find_hashtag_name(input)
        puts input[:hashtag_name]
        puts input[:Instagram_posts] = recent_post_from_instagram(input[:hashtag_name])

        Success(input)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
      end

      def store_post(input)
        new_po = input[:Instagram_posts]

        new_po.map do |new_post|
          Repository::For.entity(new_post).create(new_post)
        end

        Repository::For.klass(Entity::RecentPost).find_full_name
          .then { |posts| Entity::RecentPostsList.new(posts) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
        # Success(post)
      rescue StandardError
        # App.logger.error("ERROR: #{e.inspect}")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      def recent_post_from_instagram(input)
        puts 'recent66'
        FlyHii::Instagram::RecentMediaMapper
          .new(App.config.INSTAGRAM_TOKEN, App.config.ACCOUNT_ID)
          .find(input)
      rescue StandardError
        raise RECENT_IG_NOT_FOUND_MSG
      end
    end
  end
end
