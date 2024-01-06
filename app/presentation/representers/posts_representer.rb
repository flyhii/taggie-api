# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'post_representer'

module FlyHii
  module Representer
    # Represents list of posts for API output
    class PostsList < Roar::Decorator
      include Roar::JSON

      collection :posts, extend: Representer::Post, class: OpenStruct
    end
  end
end
