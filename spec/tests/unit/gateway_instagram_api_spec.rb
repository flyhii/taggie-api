# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'

describe 'Tests Instagram API library' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_instagram
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Media information' do
    before do
      @media_info = FlyHii::Instagram::MediaMapper
        .new(INSTAGRAM_TOKEN, ACCOUNT_ID)
        .find(HASHTAG_NAME)
    end

    # wait for revise

    it 'HAPPY: should provide correct media attributes' do
      media_info =
        FlyHii::Instagram::MediaMapper
          .new(INSTAGRAM_TOKEN, ACCOUNT_ID)
          .find(HASHTAG_NAME)

      media_info.map do |media|
        _(media.id).must_equal CORRECT['id']
        _(media.caption).must_equal CORRECT['caption']
        _(media.comments_count).must_equal CORRECT['comments_count']
        _(media.like_count).must_equal CORRECT['like_count']
        _(media.timestamp).must_equal CORRECT['timestamp']
        _(media.media_url).must_equal CORRECT['media_url']
      end
    end

    it 'BAD: should raise exception on incorrect post' do
      _(proc do
        FlyHii::Instagram::MediaMapper
          .new(INSTAGRAM_TOKEN, ACCOUNT_ID)
          .find('fake_hashtag_name')
      end).must_raise FlyHii::Instagram::Api::Response::NotFound
    end

    it 'BAD: should raise exception when unauthorized' do
      _(proc do
        FlyHii::Instagram::MediaMapper
          .new('BAD_TOKEN', ACCOUNT_ID)
          .find(HASHTAG_ID)
      end).must_raise FlyHii::Instagram::Api::Response::Unauthorized
    end
  end
end
