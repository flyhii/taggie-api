# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

# Represents essential Repo information for API output
module FlyHii
  module Representer
    # Represent a Post entity as Json
    class RecentPost < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :id
      property :remote_id
      property :caption
      property :tags
      property :comments_count
      property :like_count
      property :timestamp
      property :media_url

      link :self do
        "#{App.config.API_HOST}/api/v1/posts/hashtag=#{hashtag_name}"
      end

      private

      def hashtag_name
        represented.id
      end
    end
  end
end
