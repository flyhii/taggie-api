# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

describe 'Add Post Service Integration Test' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_instagram(recording: :none)
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store post' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to find and save remote post to database' do
      # GIVEN: a valid url request for existing remote post:
      instagram_media = FlyHii::Instagram::MediaMapper
        .new(INSTAGRAM_TOKEN, ACCOUNT_ID)
        .find(HASHTAG_NAME)
      url_request = FlyHii::Forms::NewPost.new.call(remote_url: IG_URL)

      # WHEN: the service is called with the request form object
      post_made = FlyHii::Service::AddPost.new.call(url_request)

      # THEN: the result should report success..
      _(post_made.success?).must_equal true

      # ..and provide a post entity with the right details
      rebuilt = post_made.value!

      _(rebuilt.id).must_equal(instagram_media.id)
      _(rebuilt.caption).must_equal(instagram_media.caption)
      _(rebuilt.comments_count).must_equal(instagram_media.comments_count)
      _(rebuilt.like_count).must_equal(instagram_media.like_count)
      _(rebuilt.timestamp).must_equal(instagram_media.timestamp)
      _(rebuilt.media_url).must_equal(instagram_media.media_url)
      _(rebuilt.children).must_equal(instagram_media.children)
      _(rebuilt.media_type).must_equal(instagram_media.media_type)

      # post.contributors.each do |member|
      #   found = rebuilt.contributors.find do |potential|
      #     potential.origin_id == member.origin_id
      #   end

      #   _(found.username).must_equal member.username
      # end
    end

    it 'HAPPY: should find and return existing post in database' do
      # GIVEN: a valid url request for a post already in the database:
      url_request = FlyHii::Forms::NewPost.new.call(remote_url: IG_URL)
      db_post = FlyHii::Service::AddPost.new.call(url_request).value!

      # WHEN: the service is called with the request form object
      post_made = FlyHii::Service::AddPost.new.call(url_request)

      # THEN: the result should report success..
      _(post_made.success?).must_equal true

      # ..and find the same post that was already in the database
      rebuilt = post_made.value!
      _(rebuilt.id).must_equal(db_post.id)

      # ..and provide a post entity with the right details
      _(rebuilt.id).must_equal(instagram_media.id)
      _(rebuilt.caption).must_equal(instagram_media.caption)
      _(rebuilt.comments_count).must_equal(instagram_media.comments_count)
      _(rebuilt.like_count).must_equal(instagram_media.like_count)
      _(rebuilt.timestamp).must_equal(instagram_media.timestamp)
      _(rebuilt.media_url).must_equal(instagram_media.media_url)

      # db_post.contributors.each do |member|
      #   found = rebuilt.contributors.find do |potential|
      #     potential.origin_id == member.origin_id
      #   end

      #   _(found.username).must_equal member.username
      # end
    end

    it 'BAD: should gracefully fail for invalid post url' do
      # GIVEN: an invalid url request is formed
      bad_ig_url = 'http://facebook.com/foobar'
      url_request = FlyHii::Forms::NewPost.new.call(remote_url: bad_ig_url)

      # WHEN: the service is called with the request form object
      post_made = FlyHii::Service::AddPost.new.call(url_request)

      # THEN: the service should report failure with an error message
      _(post_made.success?).must_equal false
      _(post_made.failure.downcase).must_include 'invalid'
    end

    it 'SAD: should gracefully fail for invalid post url' do
      # GIVEN: an invalid url request is formed
      sad_ig_url = 'http://facebook.com/wfkah4389/foobarsdhkfw2'
      url_request = FlyHii::Forms::NewPost.new.call(remote_url: sad_ig_url)

      # WHEN: the service is called with the request form object
      post_made = FlyHii::Service::AddPost.new.call(url_request)

      # THEN: the service should report failure with an error message
      _(post_made.success?).must_equal false
      _(post_made.failure.downcase).must_include 'could not find'
    end
  end
end
