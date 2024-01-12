# frozen_string_literal: true

require 'http'
require 'httparty'
require 'yaml'

require_relative '../../domain/translation/mappers/transtext_mapper'

module FlyHii
  module GoogleTranslate
    # Library for Google Translation Web API
    class Api
      API_GOOGLE_ROOT = 'https://translation.googleapis.com/language/translate/v2'

      def initialize(token)
        @google_token = token
      end

      def translation(target_language, content)
        Request.new(API_GOOGLE_ROOT, @google_token)
          .translation_url(target_language, content)
      end

      # request url
      class Request
        def initialize(resource_root, token)
          @resource_root = resource_root
          @token = token
        end

        def translation_url(target_language, content)
          puts url = "#{@resource_root}?target=#{target_language}&key=#{@token}&q=#{content}"
          GoogleApiResponseHandler.handle(url)
        end
      end

      # increase one module to deal with HTTP request
      module HTTPRequestHandler
        def self.get(url)
          HTTParty.get(url)
        end
      end

      # take the get url response
      class GoogleApiResponseHandler
        def self.handle(url)
          # use new HTTPRequestHandler
          response = HTTPRequestHandler.get(url)

          Response.new(response).tap do |inner_response|
            raise(inner_response.error) unless inner_response.successful?
          end
        end
      end

      # Decorates HTTP responses from Instagram with success/error reporting
      class Response < SimpleDelegator
        # Represents an unauthorized access error
        Unauthorized = Class.new(StandardError)
        # Represents a not found error
        NotFound = Class.new(StandardError)

        HTTP_ERROR = {
          401 => Unauthorized,
          404 => NotFound
        }.freeze

        def successful?
          HTTP_ERROR.keys.none?(code)
        end

        def error
          HTTP_ERROR[code]
        end
      end
    end
  end
end
