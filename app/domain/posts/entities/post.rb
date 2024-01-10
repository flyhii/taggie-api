# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

# require_relative 'hashtag'

module FlyHii
  module Entity
    # Domain entity for any coding media info
    class Post < Dry::Struct
      include Dry.Types

      attribute :id,              Integer.optional
      attribute :remote_id,       Strict::String
      attribute :caption,         Strict::String
      attribute :tags,            Strict::String
      attribute :comments_count,  Strict::Integer
      attribute :like_count,      Strict::Integer.optional
      attribute :timestamp,       Strict::Time
      attribute :media_url,       Strict::String.optional
      attribute :trans_caption,   Strict::String.optional

      def to_attr_hash
        # to_hash.reject { |key, _| %i[id owner contributors].include? key }
        to_hash.except(:id)
      end
    end
  end
end
