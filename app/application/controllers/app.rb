# frozen_string_literal: true

require 'roda'

module FlyHii
  # Web App
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows DELETE and other HTTP verbs beyond GET/POST

    # use Rack::MethodOverride # for other HTTP verbs (with plugin all_verbs)

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
          routing.on 'translate' do
            routing.on String do |language|
              # POST /api/v1/posts/translate
              routing.post do
                language ||= 'en' # Set a default target language if not provided

                result = Service::TranslateAllPosts.new.call(
                  target_language: language
                )
                puts "translated result: #{result}"
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

          routing.on String do |hashtag_name|
            # GET /posts/{hashtag_name}
            routing.get do
              puts '8'
              App.configure :production do
                response.cache_control public: true, max_age: 300
              end
              puts 'Are you a teapot?'
              result_rank = Service::RankHashtags.new.call(
                hashtag_name:
              )
              puts "result_rank: #{result_rank}"

              # trans_caption = Service::TranslateAllPosts.new.call(
              #   target_language: 'fr'
              # )
              # puts "translated: #{trans_caption}"

              if result_rank.failure?
                failed = Representer::HttpResponse.new(result_rank.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result_rank.value!)
              response.status = http_response.http_status_code
              Representer::RankedHashtags.new(result_rank.value!.message).to_json
              # ranked_hashtags
            end

            # POST /posts/{hashtag_name}
            routing.post do
              puts '6'
              result = Service::AddPost.new.call(
                hashtag_name:
              )
              puts 'result'
              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                puts failed.http_status_code
                routing.halt failed.http_status_code, failed.to_json
              end
              http_response = Representer::HttpResponse.new(result.value!)
              puts http_response.http_status_code
              puts '111'
              response.status = http_response.http_status_code

              puts result.value!.message

              recent_result = Service::AddRecentPost.new.call(
                hashtag_name:
              )
              puts "recentresult=#{recent_result}"
              # if recent_result.failure?
              #   failed = Representer::HttpResponse.new(recent_result.failure)
              #   puts failed.http_status_code
              #   routing.halt failed.http_status_code, failed.to_json
              # end
              # http_response = Representer::HttpResponse.new(recent_result.value!)
              # puts http_response.http_status_code
              # puts '699'
              # response.status = http_response.http_status_code
              # post_lists.to_json
              # binding.irb
              # puts result.value!.message
              # puts recent_result.value!.message
              Representer::PostsList.new(result.value!.message).to_json
              # Representer::RecentPostsList.new(recent_result.value!.message).to_json
            end
          end

          

          # routing.is do
          #   # GET /projects?list={base64_json_array_of_project_fullnames}
          #   routing.get do
          #     list_req = Request::EncodedPostList.new(routing.params)
          #     puts routing.params
          #     puts '7:48'
          #     result = Service::ListPost.new.call(list_request: list_req)

          #     if result.failure?
          #       failed = Representer::HttpResponse.new(result.failure)
          #       routing.halt failed.http_status_code, failed.to_json
          #       puts failed.http_status_code
          #     end

          #     http_response = Representer::HttpResponse.new(result.value!)
          #     puts response.status = http_response.http_status_code
          #     Representer::PostsList.new(result.value!.message).to_json
          #   end
          # end
        end
      end
    end
  end
end
