# frozen_string_literal: true

require_relative 'progress_publisher'

module TranslateText
  # Reports job progress to client
  class JobReporter
    attr_accessor :caption

    def initialize(request_json, config)
      puts 'jobreporter init'
      show_request = FlyHii::Representer::TranslateRequest
        .new(OpenStruct.new) # rubocop:disable Style/OpenStructUse
        .from_json(request_json)

      @token = config
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
