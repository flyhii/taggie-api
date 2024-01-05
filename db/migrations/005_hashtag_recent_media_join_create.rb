# rubocop:disable Layout/EndOfLine
# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:hashtag_recent_media) do
      primary_key [:hashtag_id, :recent_media_id] # rubocop:disable Style/SymbolArray
      foreign_key :hashtag_id, :hashtags
      foreign_key :recent_media_id, :recentposts

      index [:hashtag_id, :recent_media_id] # rubocop:disable Style/SymbolArray
    end
  end
end

# rubocop:enable Layout/EndOfLine
