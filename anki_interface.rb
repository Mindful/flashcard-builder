# encoding: utf-8
#Expression, Meaning, Reading, Example
require 'mojinizer'

ADD_END_TO_NA_ADJECTIVES = true
#array.any?{ |s| s.casecmp(mystr)==0 } is case insensitive include?

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

	def csv_format
		display_expression = @expression

		#Intentional spaces in strings after the particle so that furigana doesn't
		#spread out over them as well

		skip_start = 0
		skip_end = 0
		last_kanji = 0
		reading_completion = 0
		reading_expression = ""	
		if @reading != nil
			(0...display_expression.size).each do |i| #three dots to exclude final value
				puts "Start round #{i} with string #{reading_expression}"
				c = display_expression[i]
				if !c.kanji? && last_kanji == i-1
					puts "Work on #{c} at #{i} as non-kanji"
					#Start skipping here, end wherever the last duplicate is,
					#and then place the previous characters in their own set
					#of brackets and keep going and set i += (skip_end-skip_start)
					skip_end = skip_start = @reading.index(c)
					display_skip_counter = i
					(skip_start...@reading.size).each do |j|
						read_c = @reading[j]
						if read_c != display_expression[display_skip_counter]
							break
						else
							puts "Skip +1 for #{read_c}"
						end
						display_skip_counter +=1	
						skip_end +=1
					end
					puts "i before change #{i}, skip_end #{skip_end}, skip_start #{skip_start}"
					i += (skip_end - skip_start)+1
					puts "i after change #{i}"
					puts "Skip string = #{@reading[skip_start..skip_end]}"
					reading_expression += "[#{@reading[reading_completion..(skip_start-1)]}]"
					reading_expression += @reading[skip_start..skip_end] #Add back the kana just once
					reading_completion = skip_end
					break if i > display_expression.size #ruby won't do this automatically for us, because ".each"
				elsif !c.kanji?
					puts "Work on #{c} as non-skip non-kanji"
					reading_expression += c
				else
					puts "Work on #{c} at #{i} as kanji"
					reading_expression += c
					last_kanji = i
				end
			end
		else
			reading_expression = display_expression
		end
		puts "Finish with string #{reading_expression}"


				#Before we finalize a strip, do a brief check to make sure
				#the next set of characters in the reading isn't identical,
				#or we could be in a situation where we are stripping furigana
				#identical to the okurigana

		if parts_of_speech.any?{|s| s.casecmp("transitive verb")==0 }
			display_expression = "を "+display_expression
		elsif parts_of_speech.any?{|s| s.casecmp("intransitive verb")==0 }
			display_expression = "が "+display_expression
		end

		display_expression = escape_quotes_in_value(display_expression)



		#TODO: Strip duplicate characters out out furigana so only kanji readings remain;
		# do this iteratively to support compound words with kanji breaks like 差し支え

		if ADD_END_TO_NA_ADJECTIVES && parts_of_speech.any?{ |s| s.casecmp("na-adjective")==0 }
			display_expression += "な"
			reading_expression += "な"
		end
		reading != nil ? "[#{escape_quotes_in_value(@reading)}]" : ""
		return "\"#{display_expression}\",\"#{escape_quotes_in_value(@meaning)}\",\"#{display_expression}#{reading_expression}\",\"#{escape_quotes_in_value(@example)}\""
	end
end
