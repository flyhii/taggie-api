# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

module FlyHii
  # Web App
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :public, root: 'app/presentation/public'
    plugin :assets, path: 'app/presentation/assets',
                    css: 'style.css', js: 'table_row.js'
    plugin :common_logger, $stderr

    use Rack::MethodOverride # allows HTTP verbs beyond GET/POST (e.g., DELETE)

    MSG_GET_STARTED = 'Search for a Hashtag to get started'

    route do |routing|
      routing.assets # load CSS
      response['Content-Type'] = 'text/html; charset=utf-8'
      routing.public

      # GET /
      routing.root do
        # Get cookie viewer's previously seen hashtags
        session[:watching] ||= []
        hashtags = session[:watching]
        flash.now[:notice] = MSG_GET_STARTED if hashtags.none?

        searched_hashtags = Views::HashtagsList.new(hashtags)

        view 'home', locals: { hashtags: searched_hashtags }
      end

      routing.on 'media' do
        routing.is do
          # POST /media/
          routing.post do
            hashtag_name = routing.params['hashtag_name'].downcase
            unless !hashtag_name.include?(' ') &&
                   !hashtag_name.include?('#')
              flash[:error] = 'Please enter a hashtag without spaces or #'
              response.status = 400
              routing.redirect '/'
            end

            # Get Posts from Instagram using hashtag_name
            begin
              posts = Instagram::MediaMapper
                .new(App.config.INSTAGRAM_TOKEN, App.config.ACCOUNT_ID)
                .find(hashtag_name)
            rescue StandardError => err
              App.logger.error err.backtrace.join("DB READ POST\n")
              flash[:error] = 'Could not find that Post'
              routing.redirect '/'
            end

            # Add Posts to database
            begin
              posts.map do |post|
                Repository::For.entity(post).create(post)
              end
            rescue StandardError
              flash[:error] = 'Post already exists'
              routing.redirect '/'
            end

            # Add new hashtag to watched set in cookies
            session[:watching].insert(0, hashtag_name).uniq!

            # Redirect viewer to hashtag page
            routing.redirect "/media/#{hashtag_name}"
          end
        end

        routing.on String do |hashtag_name|
          # DELETE /media/{hashtag_name}
          routing.delete do
            full_tag_name = hashtag_name.to_s
            session[:watching].delete(full_tag_name)

            routing.redirect '/'
          end

          # GET /media/{hashtag_name}
          routing.get do
            # path = request.remaining_path
            # folder_name = path.empty? ? '' : path[1..]

            # Get post from database instead of Instagram
            begin
              puts hashtag_name
              posts = Repository::For.klass(Entity::Post)
                .find_full_name

              if posts.nil?
                flash[:error] = 'Hashtag not found'
                routing.redirect '/'
              end
            rescue StandardError
              flash[:error] = 'app Having trouble accessing the database'
              routing.redirect '/'
            end

            ### TODO: Ranking in different ways
            # Rank all hashtags by counting appearances in all posts
            # begin
            #   tags = Mapper::Ranking ### TODO: add ranker in Mapper
            #     .new(tag_name)
            # rescue StandardError
            #   flash[:error] = 'Having problem doing ranking'
            #   routing.redirect '/'
            # end

            # if tags.empty?
            #   flash[:error] = 'Could not find those tags'
            #   routing.redirect '/'
            # end

            # ranking_list = Views::RankedList.new(hashtag_name)

            # Show viewer the posts information
            view 'media', locals: { posts: }

            # past media to rank repository
            # GetMedia.new(media)

            # view 'media', locals: { media: }
          end
        end
      end
    end
  end
end
