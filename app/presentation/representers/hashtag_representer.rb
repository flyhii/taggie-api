# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module FlyHii
  module Representer
    # Represents a CreditShare value
    class Hashtag < Roar::Decorator
      include Roar::JSON

      property :hashtag_name
    end
  end
end
