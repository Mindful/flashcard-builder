require 'csv'
require './anki_interface.rb'
require './jisho_interface.rb'

LINE_SEPARATOR = "--------------------------------"
DEFINITION_SEPARATOR = ";"

def jisho_word_to_anki_card(word)
	#(expression, meaning, reading, example)
	count = 0
	parts_of_speech = []
	meanings = word.senses.map do |sense|
		sense.parts_of_speech.each {|part| parts_of_speech << part}
		count +=1
		if word.senses.length > 1
			count.to_s + ". " + sense.definitions.join("#{DEFINITION_SEPARATOR} ")
		else
			sense.definitions.join("#{DEFINITION_SEPARATOR} ")
		end
	end
	meanings = meanings.join("\n")
	card = AnkiCard.new(parts_of_speech, word.content, meanings, word.reading, "")

end

def main
	filename = ARGV[0]
	if !filename
		puts "Please pass in filename as argument"
		exit
	end

	output_file = File.open("flashcard_output_#{Time.now.to_i}", 'w')

	CSV.foreach("#{filename}") do |row|
 		row.each do |word|
 			puts LINE_SEPARATOR
 			dictionary_result = search(word)[0]
 			puts dictionary_result.inspect
 			dictionary_result = jisho_word_to_anki_card(dictionary_result)
 			output_file.write(dictionary_result.csv_format + "\n")
 		end
	end
	puts LINE_SEPARATOR
end

main