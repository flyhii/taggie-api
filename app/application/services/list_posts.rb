# frozen_string_literal: true

require 'dry/transaction'

module FlyHii
  module Service
    # Retrieves array of all listed post entities
    class ListPost
      include Dry::Transaction

      step :validate_list
      step :retrieve_post

      private

      DB_ERR = 'Cannot access database'

      # Expects list of movies in input[:list_request]
      def validate_list(input)
        list_request = input[:list_request].call
        if list_request.success?
          Success(input.merge(list: list_request.value!))
        else
          Failure(list_request.failure)
        end
      end

      def retrieve_post(input)
        Repository::For.klass(Entity::Post).find_full_names(input[:list])
          .then { |post| Response::PostsList.new(post) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR)
        )
      end
    end
  end
end
