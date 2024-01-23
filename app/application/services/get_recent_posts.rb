# frozen_string_literal: true

require 'dry/transaction'

module FlyHii
  module Service
    # Transaction to store post from Instagram API to database
    class GetRecentPost
      include Dry::Transaction

      step :recent_posts

      private

      DB_ERR_MSG = 'Having trouble accessing the database'
      RECENT_IG_NOT_FOUND_MSG = 'Could not find that recent post on Instagram'

      def recent_posts
        Repository::For.klass(Entity::RecentPost).find_full_name
          .then { |posts| Entity::RecentPostsList.new(posts) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
        # Success(post)
      rescue StandardError
        # App.logger.error("ERROR: #{e.inspect}")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end
    end
  end
end
