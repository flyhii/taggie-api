# frozen_string_literal: true

require_relative 'progress_publisher'

module ShowPost
  # Reports job progress to client
  class JobReporter
    attr_accessor :post

    def initialize(request_json, config)
      show_request = FlyHii::Representer::ShowRequest
        .new(OpenStruct.new)
        .from_json(request_json)

      @post = show_request.caption
      @publisher = ProgressPublisher.new(config, show_request.id)
    end

    def report(msg)
      @publisher.publish msg
    end

    def report_each_second(seconds, &operation)
      seconds.times do
        sleep(1)
        report(operation.call)
      end
    end
  end
end
