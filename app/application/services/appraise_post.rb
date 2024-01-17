# frozen_string_literal: true

require 'dry/transaction'

module FlyHii
  module Service
    # Analyzes ranking to a post
    class AppraisePost
      include Dry::Transaction

      step :retrieve_remote_post
      # step :clone_remote
      step :appraise_ranking

      private

      NO_PROJ_ERR = 'Post not found'
      DB_ERR = 'Having trouble accessing the database'
      NO_FOLDER_ERR = 'Could not find that folder'

      # Steps

      def retrieve_remote_post(input)
        input[:post] = Repository::For.klass(Entity::Post).find_full_name(
          input[:requested].owner_name, input[:requested].post_name
        )

        input[:post] ? Success(input) : Failure(Response::ApiResult.new(status: :not_found, message: NO_PROJ_ERR))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end

      # About processing
      # Messaging::Queue.new(App.config.TRANSLATE_QUEUE_URL, App.config)
      #     .send(clone_request_json(input))

      #     Failure(Response::ApiResult.new(
      #       status: :processing,
      #       message: { request_id: input[:request_id], msg: PROCESSING_MSG }
      #     ))

      # def clone_request_json(input)
      #   Response::CloneRequest.new(input[:project], input[:request_id])
      #     .then { Representer::CloneRequest.new(_1) }
      #     .then(&:to_json)
      # end

      # can skip
      # def clone_remote(input)
      #   gitrepo = GitRepo.new(input[:post])
      #   gitrepo.clone! unless gitrepo.exists_locally?

      #   Success(input.merge(gitrepo:))
      # rescue StandardError
      #   App.logger.error error.backtrace.join("\n")
      #   Failure(Response::ApiResult.new(status: :internal_error, message: CLONE_ERR))
      # end

      def appraise_ranking(input)
        input[:folder] = Mapper::Contributions
          .new(input[:gitrepo]).for_folder(input[:requested].folder_name)

        Success(input)
      rescue StandardError
        App.logger.error "Could not find: #{full_request_path(input)}"
        Failure(Response::ApiResult.new(status: :not_found, message: NO_FOLDER_ERR))
      end

      # Helper methods

      def full_request_path(input)
        [input[:requested].owner_name,
         input[:requested].project_name,
         input[:requested].folder_name].join('/')
      end

      def log_error(error)
        App.logger.error [error.inspect, error.backtrace].flatten.join("\n")
      end
    end
  end
end
