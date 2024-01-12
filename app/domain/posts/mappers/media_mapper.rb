# frozen_string_literal: true

require 'date'

module FlyHii
  # Provides access to media data
  module Instagram
    # Data Mapper: Instagram media -> Media entity
    class MediaMapper
      def initialize(ig_token, user_id, gateway_class = Instagram::Api)
        @token = ig_token
        @ig_user_id = user_id
        @gateway = gateway_class.new(@token, @ig_user_id)
        @posts = []
      end

      def find(hashtag_name)
        puts '4'
        puts hashtag_name
        hashtag_id = get_hashtag_id(hashtag_name)
        puts hashtag_id
        @posts = get_media_content(hashtag_id)
        puts @posts
        build_entity
      end

      def get_hashtag_id(hashtag_name)
        HashtagMapper.new(@token, @ig_user_id).find(hashtag_name)
      end

      def get_media_content(hashtag_id)
        media_content = @gateway.media(hashtag_id)
        media_content['data']
      end

      def build_entity
        @posts.map do |post|
          DataMapper.new(post).build_entity
        end
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity # rubocop:disable Metrics/MethodLength
          Entity::Post.new(
            id: nil,
            remote_id:,
            caption:,
            tags:,
            comments_count:,
            like_count:,
            timestamp:,
            media_url:,
            trans_caption: nil
          )
        end

        def remote_id
          @data['id']
        end

        def caption
          @data['caption']
        end

        def tags
          # puts "tags = #{@data['caption'].scan(/#([^#\s]+)/).flatten.join(' ')}"
          @data['caption'].scan(/#([^#\s]+)/).flatten.join(' ')
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

        # def trans_caption
        #   @data = nil
        # end
      end
    end
  end
end
