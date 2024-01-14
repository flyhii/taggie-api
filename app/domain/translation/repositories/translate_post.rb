# frozen_string_literal: true

module FlyHii
  module Repository
    # Repository for Meida
    class Translation
    #   def self.all
    #     Database::MediaOrm.all.map { |db_post| rebuild_entity(db_post) }
    #   end

      def self.create(translated_result)
        puts 'create'
        puts translated_result
        translated_result.each do |key, value|
          puts "key=#{key}"
          puts "value=#{value}"
          add_translation(key, value)
        end
      end

      def self.add_translation(remote_id, translatedtext)
        db_record = Database::MediaOrm.first(remote_id:)
        puts "db_record=#{db_record[:caption]}"
        update_entity(db_record, translatedtext)
      end

      def self.update_entity(db_record, translatedtext)
        puts 'update_entity'
        puts db_record
        puts translatedtext
        db_record.update(trans_caption: translatedtext)
        puts "Updated translated caption: #{db_record[:trans_caption]}"
        db_record
      end

    #   def self.find(entity)
    #     puts 'find'
    #     find_remote_id(entity.remote_id)
    #   end

    #   def self.find_full_name
    #     puts 'find_full_name'
    #     db_info = Database::MediaOrm.all
    #   def self.find(entity)
    #     puts 'find'
    #     find_remote_id(entity.remote_id)
    #   end

    #   def self.find_full_name
    #     puts 'find_full_name'
    #     db_info = Database::MediaOrm.all
    #     # TODO: find_full_name for app/controller
    #     db_info.map do |db_post|
    #       puts "db_post=#{db_post}"
    #       rebuild_entity(db_post)
    #     end
    #   end

    #   def self.find_full
    #     puts 'find_full'
    #     db_info = Database::MediaOrm.limit(2).all
    #     db_info.map do |db_post|
    #       puts "db_post=#{db_post}"
    #       rebuild_entity(db_post)
    #     end
    #   end

    #   def self.find_remote_id(remote_id)
    #     db_record = Database::MediaOrm.first(remote_id:)
    #     db_record.translated_post()
    #   end

    #   def self.create(entity)
    #     raise 'Post already exists' if find(entity)

    #     puts entity.remote_id
    #     db_post = PersistPost.new(entity).call
    #     rebuild_entity(db_post)
    #   end

    #   def self.rebuild_entity(db_record)
    #     return nil unless db_record

    #     Entity::Post.new(db_record)
    #   end

      # Helper class to persist post to database
      class PersistPost
        def initialize(entity)
          @entity = entity
        end

        # def create_post
        #   Database::MediaOrm.create(@entity.to_attr_hash)
        # end

        def add_translation
          Database::MediaOrm.find(@entity)
        end
      end
    end
  end
end
