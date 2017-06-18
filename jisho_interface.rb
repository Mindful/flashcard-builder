require 'open-uri'
require 'json'
require 'mojinizer' 


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
		#Apparently there are words on jisho.org that have bad data under their parts of speech
		#and return null list entries, which causes problems unless we remove them. See:
		#http://jisho.org/search/%E8%99%AB%E3%81%8C%E3%81%84%E3%81%84\
		bad_data = @parts_of_speech.compact!
		debug "Bad speech part detected and removed" if bad_data
		@definitions = sense_hash['english_definitions']
	end
end

class JishoWord
	attr_reader :common, :content, :reading, :senses, :sensitive
	@@problem_words = []

	def self.get_problem_words
		@@problem_words
	end

	def initialize(word_hash)
		@common = word_hash['is_common']
		@content = word_hash['japanese'][0]['word']
		@reading = word_hash['japanese'][0]['reading']
		if @content == nil and @reading != nil
			@content = @reading
			@reading = nil
			#This is the case where the word is not (ever) written with Kanji
		end
		@senses = word_hash['senses'].map {|x| Sense.new(x)}.select {|x| !x.definitions.nil? }
		@sensitive = word_hash['tags'].include? 'Sensitive'

		#Weed out pesky definitions that include the word's romaji
		romaji = @reading ? @reading.romaji : @content 
		@senses.delete_if do |sense|  
			delete = sense.definitions.any?{ |d| d.casecmp(romaji)==0 }
			if delete
				debug "Removing sense #{sense.inspect} from word #{self.inspect} because of romaji duplication \"#{romaji}\""
			end
			delete
		end
	end
end

def compare_word(word, possibilities)
	possibilities.each do |w|
		return true if w == word
	end
	return false
end

def search(word)
	api_results = open(URI.encode("http://jisho.org/api/#{API_VERSION}/search/words?keyword=#{word}")).read
	api_hash = JSON.parse(api_results)
	if api_hash['meta']['status']!=200
		error "Status response not 200"
		exit
	end
	words = api_hash['data'].map {|x| [x['japanese'][0]['word'], x['japanese'][0]['reading']]}
	if words.size > 0 && !compare_word(word, words[0])
		found = words.index {|x| compare_word(word, x)}
		if !found
			warn_string = "jisho.org search result did not include an exact match for "+
			"search term <#{word}> in content or reading"
		else 
			warn_string = "jisho.org <#{word}> is at index #{found} in search result, and only" +
			" the result at index 0 is used"
		end
		warning warn_string + ". The output for this word may not be correct"
		JishoWord.get_problem_words << word
	end
	results_data = api_hash['data'].map {|x| JishoWord.new(x)}
	return results_data
end