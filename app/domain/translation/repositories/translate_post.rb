# frozen_string_literal: true

module FlyHii
  module Repository
    # Repository for Meida
    class Translation
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

      # Helper class to persist post to database
      class PersistPost
        def initialize(entity)
          @entity = entity
        end

        def add_translation
          Database::MediaOrm.find(@entity)
        end
      end
    end
  end
end
