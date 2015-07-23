require 'open-uri'
require 'json'

MOJINIZER_DISABLED = false
begin
  require 'mojinizer' 
rescue LoadError
	MOJINIZER_DISABLED = true
end

if MOJINIZER_DISABLED
	puts "Could not get mojinizer; make sure bundle is installed. Runs without mojinizer cannot check for duplicate romaji definitions"
end


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
	attr_reader :definitions, :parts_of_speech
	def initialize(sense_hash)
		@parts_of_speech = sense_hash['parts_of_speech']
		@definitions = sense_hash['english_definitions']
	end
end

class Word
	attr_reader :common, :content, :reading, :senses, :sensitive
	def initialize(word_hash)
		@common = word_hash['is_common']
		@content = word_hash['japanese'][0]['word']
		@reading = word_hash['japanese'][0]['reading']
		if @content == nil and @reading != nil
			@content = @reading
			@reading = nil
			#This is the case where the word is not (ever) written with Kanji
		end
		@senses = word_hash['senses'].map {|x| Sense.new(x)}
		@sensitive = word_hash['tags'].include? 'Sensitive'

		#Weed out pesky definitions that include the word's romaji
		romaji = @reading ? @reading.romaji : @content 
		@senses.delete_if do |sense|  
			delete = sense.definitions.any?{ |d| d.casecmp(romaji)==0 }
			if delete
				puts "Removing sense #{sense.inspect} from word #{self.inspect} because of romaji duplication \"#{romaji}\""
			end
			delete
		end
	end
end


def search(word)
	api_results = open(URI.encode("http://jisho.org/api/#{API_VERSION}/search/words?keyword=#{word}")).read
	api_hash = JSON.parse(api_results)
	if api_hash['meta']['status']!=200
		#then we have a problem; abort
		puts "Error, status response not 200"
		exit
	end
	results_data = api_hash['data'].map {|x| Word.new(x)}
	return results_data
end