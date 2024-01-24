# frozen_string_literal: true

require_relative 'progress_publisher'

module TranslateText
  # Reports job progress to client
  class JobReporter
    attr_accessor :caption, :remote_id

    def initialize(request_json, config)
      puts 'jobreporter init'
      show_request = JSON.parse(request_json)
      # show_request = FlyHii::Representer::TranslateRequest
      #   .new(OpenStruct.new)
      #   .from_json(request_json)
      puts 'outside'
      puts show_request

      @token = config
      # @caption = show_request.caption
      show_request.each do |post|
        @remote_id = post['post_id']
        @post = post['all_posts']
        puts "remote_id: #{@remote_id}"
        puts "post: #{@post}"
        @publisher = ProgressPublisher.new(config, @remote_id)
      end

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
