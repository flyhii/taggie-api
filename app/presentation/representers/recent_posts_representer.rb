# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'recent_post_representer'

module FlyHii
  module Representer
    # Represents list of projects for API output
    class RecentPostsList < Roar::Decorator
      include Roar::JSON

      collection :recentposts, extend: RecentPost, class: OpenStruct
    end
  end
end
