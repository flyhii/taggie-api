# frozen_string_literal: true

module FlyHii
  # Maps over local and remote git repo infrastructure
  class GetMedia
    class Errors
      NoMediaFound = Class.new(StandardError)
    end

    def initialize(media:)
      @media = media
    end

    def delete
      @media.delete
    end

    def call
      raise Errors::NoMediaFound if @media.empty?

      @media
    end
  end
end
