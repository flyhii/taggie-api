# frozen_string_literal: true

require 'date'

module FlyHii
  # Provides access to media data
  module Instagram
    # Data Mapper: Instagram media -> Media entity
    class RecentMediaMapper
      def initialize(ig_token, user_id, gateway_class = Instagram::Api)
        @token = ig_token
        @ig_user_id = user_id
        @gateway = gateway_class.new(@token, @ig_user_id)
        @recentposts = []
      end

      def find(hashtag_name)
        hashtag_id = get_hashtag_id(hashtag_name)
        @recentposts = get_media_content(hashtag_id)
        puts 'recent'
        puts @recentposts
        build_entity
      end

      def get_hashtag_id(hashtag_name)
        HashtagMapper.new(@token, @ig_user_id).find(hashtag_name)
      end

      def get_media_content(hashtag_id)
        media_content = @gateway.recent_post(hashtag_id)
        media_content['data']
      end

      def build_entity
        @recentposts.map do |recentpost|
          DataMapper.new(recentpost).build_entity
        end
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          Entity::RecentPost.new(
            id: nil,
            remote_id:,
            caption:,
            tags:,
            comments_count:,
            like_count:,
            timestamp:,
            media_url:
          )
        end

        def remote_id
          @data['id']
        end

        def caption
          @data['caption']
        end

        def tags
          @data['caption'].scan(/#([^\s]+)/).flatten.join(' ')
        end

        def comments_count
          @data['comments_count']
        end

        def like_count
          @data['like_count']
        end

        def timestamp
          Time.parse(@data['timestamp'])
        end

        def media_url
          @data['media_url']
        end
      end
    end
  end
end
