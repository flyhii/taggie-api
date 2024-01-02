# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

# Represents essential Repo information for API output
module FlyHii
  module Representer
    # Represent a Post entity as Json
    class Post < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :remote_id
      property :caption
      property :comments_count
      property :like_count
      property :timestamp
      property :media_url
      # property :owner, extend: Representer::Member, class: OpenStruct
      # collection :contributors, extend: Representer::Member, class: OpenStruct

      link :self do
        "#{App.config.API_HOST}/api/v1/hashtags/#{hashtag_name}"
      end

      private

      def hashtag_name
        represented.name
      end
    end
  end
end
