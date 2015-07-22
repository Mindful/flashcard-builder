require 'csv'
require './anki_interface.rb'
require './jisho_interface.rb'

def jisho_word_to_anki_card(word)
	#(expression, meaning, reading, example)
	count = 0
	meanings = word.senses.map do |sense|
		count +=1
		if word.senses.length > 1
			count.to_s + ". " sense.definitions.join(", ")
		else
			sense.definitions.join(", ")
		end
	end
	meanings = meanings.join("\n")
	card = AnkiCard.new(word.content, meanings, word.reading, "")

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
 			dictionary_result = search(word)[0]
 			puts dictionary_result.inspect
 			dictionary_result = jisho_word_to_anki_card(dictionary_result)
 			output_file.write(dictionary_result.csv_format + "\n")
 		end
	end
end

main