# rubocop:disable Layout/EndOfLine
# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:recentposts) do
      primary_key :id

      String      :remote_id
      String      :caption
      String      :tags
      Integer     :comments_count
      Integer     :like_count
      Time        :timestamp
      String      :media_url
      String      :trans_caption

      DateTime :created_at
      DateTime :updated_at
    end
  end
end

# rubocop:enable Layout/EndOfLine
