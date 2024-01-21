# frozen_string_literal: true

require 'dry/transaction'

module FlyHii
  module Service
    # Retrieves array of all listed post entities
    class ShowTranslatePosts
      include Dry::Transaction

      step :store_post

      private

      DB_ERR_MSG = 'Cannot access database'

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
    end
  end
end
