require 'rubygems'
require 'twitter'
require 'yaml'

class TwitterApi
	attr_reader :client

	desc "collect", "Collect and store tweets using Twitter Search TwitterApi"
	def initialize
		keys = YAML.load_file('application.yml')

		@client = Twitter::REST::Client.new do |config|
			config.consumer_key        = keys['CONSUMER_KEY']
  			config.consumer_secret     = keys['CONSUMER_KEY_SECRET']
  			config.access_token        = keys['ACCESS_TOKEN']
  			config.access_token_secret = keys['ACCESS_TOKEN_SECRET']
		end
	end

	file = "tweets.txt"

	keywordList = ["follow", "lol", "follower"]

	numTweeters = 10

	target = open(file, 'a+')
	arr = []

	keywordList.each do |keyword|
		puts "Scraping #{numTweeters} #{keyword} tweets"
		client.search("#{keyword} -rt", result_type: "recent").take(numTweeters).collect do |tweet|
			arr.push(tweet.user.screen_name)
		end
	end
end	
