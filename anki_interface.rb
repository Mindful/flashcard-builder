# encoding: utf-8
#Expression, Meaning, Reading, Example

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
		if ADD_END_TO_NA_ADJECTIVES && parts_of_speech.any?{ |s| s.casecmp("na-adjective")==0 }
			display_expression += "な"
		elsif parts_of_speech.any?{|s| s.casecmp("transitive verb")==0 }
			display_expression = "を"+display_expression
		elsif parts_of_speech.any?{|s| s.casecmp("intransitive verb")==0 }
			display_expression = "が"+display_expression
		end

		display_expression = escape_quotes_in_value(display_expression)
		reading_expression = reading != nil ? "[#{escape_quotes_in_value(@reading)}]" : ""
		return "\"#{display_expression}\",\"#{escape_quotes_in_value(@meaning)}\",\"#{display_expression}#{reading_expression}\",\"#{escape_quotes_in_value(@example)}\""
	end
end
