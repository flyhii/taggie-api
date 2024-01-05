# rubocop:disable Layout/EndOfLine
# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:hashtag_media) do
      primary_key [:hashtag_id, :media_id] # rubocop:disable Style/SymbolArray
      foreign_key :hashtag_id, :hashtags
      foreign_key :media_id, :posts

      index [:hashtag_id, :media_id] # rubocop:disable Style/SymbolArray
    end
  end
end

# rubocop:enable Layout/EndOfLine
