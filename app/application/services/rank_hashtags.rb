# frozen_string_literal: true

require 'dry/transaction'

module FlyHii
  module Service
    # Analyzes ranking to a post
    class RankHashtags
      include Dry::Transaction

      step :find_local_post
      step :ranked_hashtags

      private

      NO_POST_ERR = 'Posts not found'
      RK_ERR = 'Having trouble ranking hashtags'

      # Steps

      def find_local_post(input)
        puts "input: #{input}"
        puts input[:local_post] = post_in_database(input[:hashtag_name])
        Success(input)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :not_found, message: NO_POST_ERR))
      end

      def ranked_hashtags(input)
        input[:ranked_hashtags] = ranking(input)

        Success(input)
      rescue StandardError
        App.logger.error "Could not find: #{input[:hashtag_name]}"
        Failure(Response::ApiResult.new(status: :not_found, message: RK_ERR))
      end

      # Helper methods

      def post_in_database(input)
        puts "post_in_database: #{input}"
        Repository::For.klass(Entity::Post)
          .find_full_name
      end

      def ranking(input)
        puts 'ranking'
        hashtags_counts = Hash.new(0)

        hashtag_array = input[:local_post].map do |post|
          post.tags.split
        end

        hashtag_array.flatten.each do |tag|
          hashtags_counts[tag] += 1
        end

        top_3_hashtag = hashtags_counts.sort_by { |_tag, count| -count }[1..3].to_h.keys
        puts "top_3_hashtag: #{top_3_hashtag}"
        top_3_hashtag
      end
    end
  end
end
