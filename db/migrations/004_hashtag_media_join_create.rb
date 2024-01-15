# rubocop:disable Layout/EndOfLine
# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:hashtag_media) do
      primary_key [:media_id, :hashtag_id] # rubocop:disable Style/SymbolArray
      foreign_key :media_id, :posts
      foreign_key :hashtag_id, :hashtags

      index [:media_id, :hashtag_id] # rubocop:disable Style/SymbolArray
    end
  end
end

# rubocop:enable Layout/EndOfLine
