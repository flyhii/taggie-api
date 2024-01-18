# frozen_string_literal: true

require_relative 'hashtags'

module FlyHii
  module Repository
    # Repository for Meida
    class Posts
      def self.all
        Database::MediaOrm.all.map { |db_post| rebuild_entity(db_post) }
      end

      def self.find(entity)
        puts 'find'
        find_remote_id(entity.remote_id)
      end

      def self.find_full_name
        puts 'find_full_name'
        db_info = Database::MediaOrm.all
        # TODO: find_full_name for app/controller
        db_info.map do |db_post|
          puts "db_post=#{db_post}"
          rebuild_entity(db_post)
        end
      end

      def self.find_full
        puts 'find_full'
        db_info = Database::MediaOrm.limit(2).all
        db_info.map do |db_post|
          puts "db_post=#{db_post}"
          rebuild_entity(db_post)
        end
      end

      # def self.find_id(id)
      #   db_record = Database::MediaOrm.first(id:)
      #   rebuild_entity(db_record)
      # end

      def self.find_remote_id(remote_id)
        db_record = Database::MediaOrm.first(remote_id:)
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

        Entity::Post.new(db_record)
      end

      # Helper class to persist post to database
      class PersistPost
        def initialize(entity)
          @entity = entity
        end

        def create_post
          Database::MediaOrm.create(@entity.to_attr_hash)
        end

        def call
          create_post
          puts 'is there a tag?'
          puts @entity.tags
          return if @entity.tags.nil?

          puts @entity.tags
          Hashtags.db_find_or_create(@entity.tags)
          puts 'hashtag added to db'
          # create_post.tap do |db_post|
          #   db_post.update(tags:)
          # end
        end
      end
    end
  end
end
