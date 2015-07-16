#Expression, Meaning, Reading, Example

class AnkiCard
	def initialize(expression, meaning, reading, example)
		@expression = expression
		@meaning = meaning
		@reading = reading
		@example = example
	end

	def csv_format
		return "#{@expression},#{@meaning},#{@reading},#{@example}"
	end
end