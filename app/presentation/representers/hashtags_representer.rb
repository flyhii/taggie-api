# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'post_representer'

module FlyHii
  module Representer
    # Represents list of hashtags for API output
    class HashtagsList < Roar::Decorator
      include Roar::JSON

      collection :hashtags, extend: Representer::Hashtag
    end
  end
end
