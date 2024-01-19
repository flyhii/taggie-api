# frozen_string_literal: true

module FlyHii
  module Representer
    # OpenStruct for deserializing json with hypermedia
    class OpenStructWithLinks < OpenStruct # rubocop:disable Style/OpenStructUse
      attr_accessor :links
    end
  end
end
