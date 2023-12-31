# frozen_string_literal: true

module FlyHii
  module Response
    SUCCESS = Set.new(
      %i[ok created processing]
    ).freeze

    FAILURE = Set.new(
      %i[forbidden not_found bad_request conflict cannot_process
         internal_error]
    ).freeze

    CODES = SUCCESS | FAILURE

    # Response object for any operation result
    ApiResult = Struct.new(:status, :message) do
      def initialize(status:, message:)
        puts '5'
        # puts status
        # puts message
        raise(ArgumentError, 'Invalid status') unless CODES.include? status

        super(status, message)
      end
    end
  end
end
