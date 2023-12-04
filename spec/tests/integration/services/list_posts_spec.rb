# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

require 'ostruct'

describe 'Ranking Posts Service Integration Test' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_instagram(recording: :none)
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Rank Post hashtags' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should return hashtags that are being rank' do
      # GIVEN: a valid post exists locally and is being watched
      ig_posts = FlyHii::Instagram::MediaMapper
        .new(INSTAGRAM_TOKEN, ACCOUNT_ID)
        .find(HASHTAG_NAME)

      db_post = ig_posts.map do |ig_post|
        FlyHii::Repository::For.entity(ig_post)
          .create(ig_post)
      end

      watched_list = [HASHTAG_NAME]

      # WHEN: we request a list of all watched posts
      result = FlyHii::Service::ListPosts.new.call(watched_list)

      # THEN: we should see our post in the resulting list
      _(result.success?).must_equal true
      posts = result.value!
      _(posts).must_include db_post
    end

    it 'HAPPY: should not return posts that are not being watched' do
      # GIVEN: a valid post exists locally but is not being watched
      ig_posts = FlyHii::Instagram::MediaMapper
        .new(INSTAGRAM_TOKEN, ACCOUNT_ID)
        .find(HASHTAG_NAME)

      ig_posts.map do |ig_post|
        FlyHii::Repository::For.entity(ig_post)
          .create(ig_post)
      end

      watched_list = []

      # WHEN: we request a list of all watched posts
      result = FlyHii::Service::ListPosts.new.call(watched_list)

      # THEN: it should return an empty list
      _(result.success?).must_equal true
      posts = result.value!
      _(posts).must_equal []
    end

    it 'SAD: should not watched posts if they are not loaded' do
      # GIVEN: we are watching a post that does not exist locally
      watched_list = [HASHTAG_NAME]

      # WHEN: we request a list of all watched posts
      result = FlyHii::Service::ListPosts.new.call(watched_list)

      # THEN: it should return an empty list
      _(result.success?).must_equal true
      posts = result.value!
      _(posts).must_equal []
    end
  end
end
