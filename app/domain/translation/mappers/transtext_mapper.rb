# frozen_string_literal: true

module FlyHii
  # Provides access to hashtag data
  module GoogleTranslate
    # Data Mapper: Instagram contributor -> Hashtag entity
    class TransTextMapper
      def initialize(google_token, gateway_class = GoogleTranslate::Api)
        @token = google_token
        @gateway = gateway_class.new(@token)
        @data = []
      end

      def translate(target_language, content)
        puts content
        @gateway.translation(target_language, content)
      end
    end
  end
end
