# frozen_string_literal: true

require 'roda'

module FlyHii
  # Web App
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows DELETE and other HTTP verbs beyond GET/POST

    # use Rack::MethodOverride # for other HTTP verbs (with plugin all_verbs)

    # rubocop:disable Metrics/BlockLength,Lint/RedundantCopDisableDirective,Lint/MissingCopEnableDirective
    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        message = "Taggie API v1 at /api/v1/ in #{App.environment} mode"

        result_response = Representer::HttpResponse.new(
          Response::ApiResult.new(status: :ok, message:)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do
        routing.on 'posts' do
          routing.on String do |hashtag_name|
            # GET /posts/{hashtag_name}
            routing.get do
              path_request = Request::PostPath.new(
                hashtag_name, request
              )

              result = Service::AppraisePost.new.call(requested: path_request)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              # TODO: change
              Representer::ProjectFolderContributions.new(
                result.value!.message
              ).to_json
            end

            # POST /posts/{hashtag_name}
            routing.post do
              result = Service::AddPost.new.call(
                hashtag_name:
              )

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::POST.new(result.value!.message).to_json
            end
          end

          routing.is do
            # GET /posts?list={base64_json_array_of_project_fullnames}
            routing.get do
              list_req = Request::EncodedPostList.new(routing.params)
              result = Service::ListPosts.new.call(list_request: list_req)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::PostsList.new(result.value!.message).to_json
            end
          end
        end
      end
    end
  end
end
