require 'open-uri'
require 'json'

API_VERSION = 'v1'

#closest thing to documentation is here 
# http://jisho.org/forum/54fefc1f6e73340b1f160000-is-there-any-kind-of-search-api

#TODO
# - JLPT level for words (jisho has this info; wish they'd share it)
# - Import example sentences somehow


#The naming of this class could be confusing, but once I realized why the API used the word,
#I also realized it's probably the best word. It's sense as in "sense of the word", because
#words used in different senses could have different meanings - and one sense can own many meanings
class Sense 
	def initialize(sense_hash)
		@part_of_speech = sense_hash['parts_of_speech'][0] || nil
		@definitions = sense_hash['english_definitions']
	end
end

class Word
	def initialize(word_hash)
		@common = word_hash['is_common']
		@content = word_hash['japanese'][0]['word']
		@reading = word_hash['japanese'][0]['reading']
		@senses = word_hash['senses'].map {|x| Sense.new(x)}
		@sensitive = word_hash['tags'].include? 'Sensitive'
	end
end


def search(word)
	api_results = open("http://jisho.org/api/#{API_VERSION}/search/words?keyword=#{word}").read
	api_hash = JSON.parse(api_results)
	if api_hash['meta']['status']!=200
		#then we have a problem; abort
		puts "Error, status response not 200"
		exit
	end
	results_data = api_hash['data'].map {|x| Word.new(x)}
	return results_data
end