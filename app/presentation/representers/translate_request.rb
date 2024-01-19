# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require_relative 'post_representer'

# Represents essential Repo information for API output
module FlyHii
  module Representer
    # Representer object for project clone requests
    class TranslateRequest < Roar::Decorator
      include Roar::JSON

      property :caption, extend: Representer::Post, class: OpenStruct
      property :remote_id, extend: Representer::Post, class: OpenStruct
    end
  end
end
