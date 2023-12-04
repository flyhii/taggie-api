# frozen_string_literal: true

require 'http'
require 'httparty'
require 'yaml'

config = YAML.safe_load_file('config/secrets.yml')
API_IG_ROOT = 'https://graph.facebook.com/v18.0'
FIELDS = 'id,caption,comments_count,like_count,timestamp,media_url,children,media_type'
HASHTAG_NAME = 'new'
HASHTAG_ID = '17842307719068454'

def get_hashtag_url(config)
  url = "#{API_IG_ROOT}/ig_hashtag_search?user_id=#{config['ACCOUNT_ID']}&q=#{HASHTAG_NAME}&access_token=#{config['INSTAGRAM_TOKEN']}"
  # HTTParty.get(url)
  HTTParty.get(url).parsed_response['data']
end

def call_ig_url(config, hashtag_id)
  url = "#{API_IG_ROOT}/#{hashtag_id}/top_media?user_id=#{config['ACCOUNT_ID']}&fields=#{FIELDS}&access_token=#{config['INSTAGRAM_TOKEN']}"
  # HTTParty.get(url)
  HTTParty.get(url).parsed_response['data']
end

ig_response = {}
ig_results = {}

## HAPPY post request
# hashtag_id = get_hashtag_url(config)

media_url = call_ig_url(config, HASHTAG_ID)
ig_response[media_url] = call_ig_url(config, HASHTAG_ID)
media = ig_response[media_url]

media.each do |media_item|
  ig_results['id'] = media_item['id']
  ig_results['caption'] = media_item['caption']
  ig_results['comments_count'] = media_item['comments_count']
  ig_results['like_count'] = media_item['like_count']
  ig_results['timestamp'] = media_item['timestamp']
  ig_results['media_url'] = media_item['media_url']
end

# contributors_url = media['contributors_url']
# ig_response[contributors_url] = call_ig_url(config, contributors_url)
# contributors = ig_response[contributors_url].parse

# ig_results['contributors'] = contributors
# contributors.count
# should be 3 contributors array

# contributors.map { |c| c['login'] }
# should be ["Yuan-Yu", "SOA-KunLin", "luyimin"]

## BAD post request
bad_hashtag_id = 'foobar'
ig_response[bad_hashtag_id] = call_ig_url(config, bad_hashtag_id)
# ig_response[bad_hashtag_id].parsed_response

File.write('spec/fixtures/instagram_results.yml', ig_results.to_yaml)
