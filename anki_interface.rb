# encoding: utf-8
#Expression, Meaning, Reading, Example
require 'mojinizer'

ADD_END_TO_NA_ADJECTIVES = true
#array.any?{ |s| s.casecmp(mystr)==0 } is case insensitive include?

def is_kanji?(char)
	return char.kanji? || char == "々"
end

class AnkiCard
	attr_reader :expression, :meaning, :reading, :example, :parts_of_speech
	def initialize(parts_of_speech, expression, meaning, reading, example)
		@expression = expression
		@meaning = meaning
		@reading = reading
		@example = example
		@parts_of_speech = parts_of_speech
	end

	def escape_quotes_in_value(value)
		value.gsub('"', '\"') if value != nil 
	end

	def self.same_type_substring(expression, counter, kanji_substring)
		substring_start = counter
		while counter < expression.size && is_kanji?(expression[counter]) == kanji_substring 
			print "Process #{is_kanji?(expression[counter]) ? "kanji" : "kana"} " + 
			"chain member <#{expression[counter]}>, "
			counter +=1
		end
		puts "Final chain: <#{expression[substring_start...counter]}>"
		return expression[substring_start...counter] #Three dots to exclude last value
	end


	#After spending a pretty substantial amount of time on this, I'm convinced that writing a
	#generalizable algorithm for assigning yomikata and okurigana generalizably from strings of
	#the reading of the entire word is simply not possible, because the variability in kanji 
	#readings means there is no good way to differentiate same-character okurigana and yomikata
	#In short, the code here should work for just about every real word, but I can find no algorithm
	#that can properly make sense of something like this:
	#expression = "き気期き気きき木き帰"
	#reading = "きききききききききき"
	def self.furigana(expression, reading)
		#In cases where there's no need
		return string if reading == nil 

		#So we don't mess with input
		expression = expression.clone
		reading = reading.clone

		result = ""
		kana_strings = []
		kanji_strings = []

		counter = 0
		while counter < expression.size
			kanji = is_kanji?(expression[counter])
			substring = same_type_substring(expression, counter, kanji)
			counter += substring.size
			if kanji
				kanji_strings << substring
			else
				kana_strings << substring
			end
		end
		puts "Start with kana string array #{kana_strings.inspect}"
		puts "Start with kanji string array #{kanji_strings.inspect}"

		#Use this boolean to adjust the pattern so we process in the correct order
		first_char_kanji = is_kanji?(expression[0])

		counter = 0
		#Add the kanji/reading and okurigana strings onto the result in alternating order
		while !kana_strings.empty? || !kanji_strings.empty?
			prev_reading = reading.clone
			if counter.even? == first_char_kanji && !kanji_strings.empty?
				kanji_append = kanji_strings.shift 
				result += kanji_append + "["

				#all the characters between the beginning of reading and the next kana string,
				#or the end if there is no kana string... is the best guess we can make for
				#the reading of the previous kanji
				reading_substring_end = kana_strings.empty? ? reading.size : reading.index(kana_strings[0])
				reading_substring = reading[0...reading_substring_end]
				result += reading_substring + "]"
				reading[reading_substring] = '' #Indexing with strings just finds the first instance of the string
				puts "Append kanji <#{kanji_append}> with reading <#{reading_substring}>"
			elsif !kana_strings.empty?
				kana_append = kana_strings.shift
				result += kana_append
				reading[0...kana_append.size] = ''
				puts "Append kana (okurigana) <#{kana_append}>"
			end
			puts "Remaining reading: <#{prev_reading}> -> <#{reading}>"
			counter += 1
		end
		return result
	end

	def csv_format
		#@expression, @reading
		display_expression = @expression.clone
		reading_expression = furigana(@expression, @reading)



		if parts_of_speech.any?{|s| s.casecmp("transitive verb")==0 }
			display_expression = "を "+display_expression
			reading_expression = "を "+reading_expression
		elsif parts_of_speech.any?{|s| s.casecmp("intransitive verb")==0 }
			display_expression = "が "+display_expression
			reading_expression = "が "+reading_expression
		end

		display_expression = escape_quotes_in_value(display_expression)

		if ADD_END_TO_NA_ADJECTIVES && parts_of_speech.any?{ |s| s.casecmp("na-adjective")==0 }
			display_expression += "な"
			reading_expression += "な"
		end
		reading != nil ? "[#{escape_quotes_in_value(@reading)}]" : ""
		return "\"#{display_expression}\",\"#{escape_quotes_in_value(@meaning)}\",\"#{reading_expression}\",\"#{escape_quotes_in_value(@example)}\""
	end
end
