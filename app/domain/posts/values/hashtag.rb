# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module FlyHii
  module Value
    # Hashtag in a post
    class Hashtag < Dry::Struct
      include Dry.Types

      attribute :hashtag_name, Strict::String
    end
  end
end
