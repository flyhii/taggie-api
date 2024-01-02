# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

# require_relative 'contributor'

module FlyHii
  module Entity
    # Entity for a one line of code from a contributor
    class HashtagRanking
      def initialize
        @posts = []
        @post = Entity::Post.new
        @hashtags_counts = Hash.new(0)
      end

      # sperate captions into hashtags
      def spit_hashtags
        @posts.each do |post|
          post.hashtags.each { |tag| @hashtags_counts[tag] += 1 }
        end
      end

      # Find the top 3 hashtags
      def find_top_3_hashtags
        puts top_3_hashtag = @hashtags_counts.sort_by { |_tag, count| -count }.first(3).to_h.keys
        top_3_hashtag
      end
    end
  end
end
