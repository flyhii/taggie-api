# frozen_string_literal: true

require_relative '../values/hashtag'

module FlyHii
  module Repository
    # Repository for Hashtag Entities
    class Hashtags
      def self.all
        Database::HashtagOrm.all.map { |db_hashtag| rebuild_value(db_hashtag) }
      end

      # def self.find_api_id(api_id)
      #   rebuild_entity Database::HashtagOrm.first(api_id:)
      # end

      def self.find_hashtag_name(hashtag_name)
        rebuild_value Database::HashtagOrm.first(hashtag_name:)
      end

      def self.rebuild_value(db_record)
        return nil unless db_record

        puts "db_record: #{db_record}"
        Value::Hashtag.new(
          hashtag_name: db_record
        )
      end

      def self.rebuild_many(db_records)
        # puts 'rebuild_many'
        db_records.map do |db_hashtag|
          Hashtags.rebuild_value(db_hashtag)
        end
      end

      def self.db_find_or_create(value)
        # puts "value: #{value}"
        tags = value.split
        # all_tags = rebuild_many(tags)
        # puts "tags: #{all_tags}"
        tags.map do |hashtag|
          hashtag_value = rebuild_value(hashtag)
          puts hashtag_value
          Database::HashtagOrm.find_or_create(hashtag_value.to_attr_hash)
        end
      end
    end
  end
end
