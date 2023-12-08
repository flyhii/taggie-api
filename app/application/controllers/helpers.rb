# frozen_string_literal: true

module FlyHii
  module Request
    # Application value for the path of a requested post
    class PostRequestPath
      def initialize(post_name, request)
        @post_name = post_name
        @request = request
        @path = request.remaining_path
      end

      attr_reader :post_name

      def folder_name
        @folder_name ||= @path.empty? ? '' : @path[1..]
      end

      def project_fullname
        @request.captures.join '/'
      end
    end
  end
end
