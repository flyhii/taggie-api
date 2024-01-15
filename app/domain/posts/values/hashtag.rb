# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module FlyHii
  module Value
    # Hashtag in a post
    class Hashtag < Dry::Struct
      include Dry.Types

      attribute :hashtag_name, Strict::String

      def to_attr_hash
        # to_hash.reject { |key, _| %i[id owner contributors].include? key }
        to_hash
      end
    end
  end
end
