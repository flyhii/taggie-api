# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module FlyHii
  module Value
    # Hashtag in a post
    class Hashtag < Dry::Struct
      include Dry.Types

      attribute :hashtag_name, Strict::String

      def initialize(hashtag_name)
        super(self.hashtag_name = hashtag_name)
      end

      def to_attr_hash
        { hashtag_name: }
      end
    end
  end
end
