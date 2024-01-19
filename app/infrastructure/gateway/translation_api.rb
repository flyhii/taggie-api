# frozen_string_literal: true

require 'net/http'
require 'http'
require 'httparty'
require 'yaml'
require 'json'

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
        puts 'google translate api'
        Request.new(API_GOOGLE_ROOT, @google_token)
          .translation_url(target_language, content)
      end

      # request url
      class Request
        def initialize(resource_root, token)
          @resource_root = resource_root
          @token = token
          @headers = {
            # 'Authorization'       => "Bearer #{`gcloud auth print-access-token`.strip}",
            # 'x-goog-user-project' => @token,
            'X-goog-api-key'      => @token,
            'Content-Type'        => 'application/json; charset=utf-8'
          }
        end

        def translation_url(target_language, content) # rubocop:disable Metrics/MethodLength
          url = URI.parse('https://translation.googleapis.com/language/translate/v2')
          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = true if url.scheme == 'https'

          request_data = {
            'q'      => content,
            'target' => target_language,
            'format' => 'text'
          }
          request_json = request_data.to_json
          response = http.post(url.path, request_json, @headers)
          puts "Response Body: #{response.body}"
          response.body
          # GoogleApiResponseHandler.handle(url)
        end
      end

      # increase one module to deal with HTTP request
      module HTTPRequestHandler
        def self.post(url)
          HTTParty.post(url)
        end
      end

      # take the get url response
      class GoogleApiResponseHandler
        def self.handle(url)
          # use new HTTPRequestHandler
          response = HTTPRequestHandler.post(url)

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
