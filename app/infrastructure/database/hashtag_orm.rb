# rubocop:disable Layout/EndOfLine
# frozen_string_literal: true

require 'sequel'

module FlyHii
  module Database
    # Object Relational Mapper for hashtag Entities
    class HashtagOrm < Sequel::Model(:hashtags)
      many_to_many :media,
                   class: :'FlyHii::Database::MediaOrm',
                   join_table: :hashtag_media,
                   left_key: :hashtag_id, right_key: :media_id

      many_to_many :recent_media,
                   class: :'FlyHii::Database::RecentMediaOrm',
                   join_table: :hashtag_recent_media,
                   left_key: :hashtag_id, right_key: :recent_media_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(hashtag_info)
        first(hashtag_name: hashtag_info[:hashtag_name]) || create(hashtag_info)
      end
    end
  end
end

# rubocop:enable Layout/EndOfLine
