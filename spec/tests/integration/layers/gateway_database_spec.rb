# frozen_string_literal: false

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

describe 'Integration Tests of Instagram API and Database' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_instagram
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store post' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to save post from Instagram to database' do
      instagram_media = FlyHii::Instagram::MediaMapper
        .new(INSTAGRAM_TOKEN, ACCOUNT_ID)
        .find(HASHTAG_NAME)

      instagram_media.map do |media|
        rebuilt = FlyHii::Repository::For.entity(media).create(media)

        _(rebuilt.id).must_equal(media.id)
        _(rebuilt.caption).must_equal(media.caption)
        _(rebuilt.comments_count).must_equal(media.comments_count)
        _(rebuilt.like_count).must_equal(media.like_count)
        _(rebuilt.timestamp).must_equal(media.timestamp)
        _(rebuilt.media_url).must_equal(media.media_url)
      end
      # _(rebuilt.contributors.count).must_equal(instagram_media.contributors.count)

      # instagram_media.contributors.each do |member|
      #   found = rebuilt.contributors.find do |potential|
      #     potential.origin_id == member.origin_id
      #   end

      #   _(found.username).must_equal member.username
      # not checking email as it is not always provided
      # end
    end
  end
end
