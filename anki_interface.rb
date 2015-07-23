# encoding: utf-8
#Expression, Meaning, Reading, Example

ADD_END_TO_NA_ADJECTIVES = true

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
		if ADD_END_TO_NA_ADJECTIVES && parts_of_speech.include?("Na-adjective")
			display_expression += "な"
		end
		display_expression = escape_quotes_in_value(display_expression)
		reading_expression = reading != nil ? "[#{escape_quotes_in_value(@reading)}]" : ""
		return "\"#{display_expression}\",\"#{escape_quotes_in_value(@meaning)}\",\"#{display_expression}#{reading_expression}\",\"#{escape_quotes_in_value(@example)}\""
	end
end
