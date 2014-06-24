#!/user/bin/env ruby
require 'rubygems'
require 'twitter'
require 'net/http'
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'parallel'

ENV['CONSUMER_KEY'] = "EnKqwgHH47GZHzq9k4p7DdsuQ"
ENV['CONSUMER_SECRET'] = "xBEzDFUkEUVMsdEMfVCrhWvWa9GSIsVbMbhAj6wzUNLvwP8vsY"
ENV['ACCESS_TOKEN_SECRET'] = "H5m4D4EkcFZuTYxneZalQUzX8lHgNfmb11Z0PLAALIigF"

def process_down_load(favorites)
  # favorites.each do |tweet|
  Parallel.each(favorites) do |tweet|
    name = '';
    url = '';
    # picture
    if tweet.media?
      tweet.media.each do |media|
        media_url = media.media_url.to_s
        name = media_url.split('/').last
        url = media_url+':large'
      end
    # mp4
    elsif tweet.uris?
      tweet.uris.each do |uri|
        page = Nokogiri::HTML(open(uri.expanded_uri.to_s))
        page.xpath("//source").each do |mp4|
          next if mp4[:type] != "video/mp4"
          url = mp4[:src]
          name = url.split('/').last
        end
      end
    end
    next if File.file?(name) || url.empty?
    begin
      File.write(name, open(url).read, {mode: 'wb'})
    rescue
      puts name, url
    end
  end
end

client = Twitter::REST::Client.new do |config|
  config.consumer_key         = ENV['CONSUMER_KEY']
  config.consumer_secret      = ENV['CONSUMER_SECRET']
  config.access_token         = "162063968-9SQukcnjZGKI7eQ6lMyVG1RrUBDX13vvpNQDouU4"
  config.access_token_secret  = ENV['ACCESS_TOKEN_SECRET']
end

# Example
# Download image that first 20.
favorites = client.favorites('_newpolaris')
process_down_load(favorites)

id = favorites.last.id
# Download image that next 20.
favorites = client.favorites('_newpolaris', {:max_id => id})
process_down_load(favorites)