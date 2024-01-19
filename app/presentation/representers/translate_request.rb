# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require_relative 'post_representer'

# Represents essential Repo information for API output
module FlyHii
  module Representer
    # Representer object for translate requests
    class TranslateRequest < Roar::Decorator
      include Roar::JSON

      # property :caption, extend: Representer::Post, class: OpenStruct # rubocop:disable Style/OpenStructUse
      # property :remote_id, extend: Representer::Post, class: OpenStruct # rubocop:disable Style/OpenStructUse
      property :caption
      property :remote_id
    end
  end
end
