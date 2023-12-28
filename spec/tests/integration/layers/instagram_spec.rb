# frozen_string_literal: true

# TODO: CHANGE THIS!!

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'

describe 'Tests Instagram API library' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_instagram
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Hashtag information' do
    before do
      @hashtag = FlyHii::Instagram::HashtagMapper
        .new(INSTAGRAM_TOKEN, ACCOUNT_ID)
        .find(HASHTAG_ID)
    end

    it 'HAPPY: should be a hashtag' do
      @hashtag.must_be_kind_of FlyHii::Value::Hashtag
    end
  end

  describe 'Post information' do
    before do
      @post = FlyHii::Instagram::MediaMapper
        .new(INSTAGRAM_TOKEN, ACCOUNT_ID)
        .find(HASHTAG_NAME)
    end

    it 'HAPPY: should provide correct posts' do
      _(@post.size).must_equal CORRECT['size']
      _(@post.ssh_url).must_equal CORRECT['git_url']
    end

    it 'BAD: should raise exception on incorrect post' do
      _(proc do
        FlyHii::Instagram::MediaMapper
        .new(INSTAGRAM_TOKEN, ACCOUNT_ID)
        .find(soghajvorhaur)
      end).must_raise FlyHii::Instagram::Api::Response::NotFound
    end

    it 'BAD: should raise exception when unauthorized' do
      _(proc do
        FlyHii::Instagram::MediaMapper
          .new('BAD_TOKEN', ACCOUNT_ID)
          .find(HASHTAG_NAME)
      end).must_raise FlyHii::Instagram::Api::Response::Unauthorized
    end
  end
end
