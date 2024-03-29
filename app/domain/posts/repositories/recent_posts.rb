# frozen_string_literal: true

require_relative 'hashtags'

module FlyHii
  module Repository
    # Repository for Meida
    class RecentPosts
      def self.all
        Database::RecentMediaOrm.all.map { |db_post| rebuild_entity(db_post) }
      end

      def self.find(entity)
        find_remote_id(entity.remote_id)
      end

      def self.find_full_name
        db_info = Database::RecentMediaOrm.all
        # TODO: find_full_name for app/controller
        db_info.map do |db_post|
          rebuild_entity(db_post)
        end
      end

      # def self.find_id(id)
      #   db_record = Database::MediaOrm.first(id:)
      #   rebuild_entity(db_record)
      # end

      def self.find_remote_id(remote_id)
        db_record = Database::RecentMediaOrm.first(remote_id:)
        rebuild_entity(db_record)
      end

      def self.create(entity)
        raise 'Post already exists' if find(entity)

        puts entity.remote_id
        db_post = PersistPost.new(entity).call
        rebuild_entity(db_post)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::RecentPost.new(db_record)
      end

      # Helper class to persist post to database
      class PersistPost
        def initialize(entity)
          @entity = entity
        end

        def create_post
          puts @entity.to_attr_hash
          Database::RecentMediaOrm.create(@entity.to_attr_hash)
        end

        def call
          create_post
          puts 'is there a tag?'
          puts @entity.tags
          return if @entity.tags.nil?

          puts @entity.tags
          Hashtags.db_find_or_create(@entity.tags)
          puts 'hashtag added to db'
        end
      end
    end
  end
end
