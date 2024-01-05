# rubocop:disable Layout/EndOfLine
# frozen_string_literal: true

require 'sequel'

module FlyHii
  module Database
    # Object-Relational Mapper for recent media Entities
    class RecentMediaOrm < Sequel::Model(:recentposts)
      many_to_many :hashtag_of_recent_media,
                   class: :'FlyHii::Database::HashtagOrm',
                   join_table: :hashtag_recent_media,
                   left_key: :recent_media_id, right_key: :hashtag_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(media_info)
        first(remote_id: media_info[:remote_id]) || create(media_info)
      end
    end
  end
end

# rubocop:enable Layout/EndOfLine
