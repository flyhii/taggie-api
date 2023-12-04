# frozen_string_literal: true

require 'dry-validation'

module FlyHii
  module Forms
    # Form validation for Instagram url
    # don't need this
    class NewPost < Dry::Validation::Contract
      API_IG_ROOT = 'https://graph.facebook.com/v18.0'
      FIELDS = 'id,caption,comments_count,like_count,timestamp,media_url,children,media_type'

      URL_REGEX = %r{(http[s]?)://(www.)?graph\.facebook\.com/.*/.*(?<!git)$}
      MSG_INVALID_URL = 'is an invalid address for a instagram hashtag'

      params do
        required(:remote_url).filled(:string)
      end

      rule(:remote_url) do
        key.failure(MSG_INVALID_URL) unless URL_REGEX.match?(value)
      end
    end
  end
end
