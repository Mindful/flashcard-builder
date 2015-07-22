#Expression, Meaning, Reading, Example

class AnkiCard
	def initialize(expression, meaning, reading, example)
		@expression = expression
		@meaning = meaning
		@reading = reading
		@example = example
	end

	def escape_quotes_in_value(value)
		value.gsub('"', '\"') if value != nil 
	end

	def csv_format
		return "\"#{escape_quotes_in_value(@expression)}\",\"#{escape_quotes_in_value(@meaning)}\",\"#{escape_quotes_in_value(@reading)}\",\"#{escape_quotes_in_value(@example)}\""
	end
end