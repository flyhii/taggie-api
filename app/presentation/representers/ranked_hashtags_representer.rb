# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'hashtag_representer'

module FlyHii
  module Representer
    # Represents a CreditShare value
    class RankedHashtags < Roar::Decorator
      include Roar::JSON

      property :rank
      collection :hashtags, extend: Representer::Hashtag,
                            class: Struct
    end
  end
end
