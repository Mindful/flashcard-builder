require 'csv'
require './anki_interface.rb'
require './jisho_interface.rb'
require './output.rb'

LINE_SEPARATOR = "--------------------------------"
DEFINITION_SEPARATOR = ";"

def jisho_word_to_anki_card(word)
	#(expression, meaning, reading, example)
	count = 0
	parts_of_speech = []
    if word == nil
    	return nil
    end
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
		error "Please pass in filename as argument"
		exit
	end

	output_file = File.open("flashcard_output_#{Time.now.to_i}", 'w')

	CSV.foreach("#{filename}") do |row|
 		row.each do |word|
 			puts LINE_SEPARATOR
 			dictionary_result = search(word)[0]
 			puts "-->".light_blue+dictionary_result.inspect
 			dictionary_result = jisho_word_to_anki_card(dictionary_result)
 			if dictionary_result == nil
 				warning "No result for <#{word}>, skipping"
 			else
 				output_file.write(dictionary_result.csv_format + "\n")
 				puts "-->".light_blue+dictionary_result.inspect
 			end
 		end
 		if AnkiCard.get_problem_words.size > 0
 			warning "Detected likely problems in the processing of words "+
 			"#{AnkiCard.get_problem_words.inspect} . It is recommended that you "+
 			"omit these words from the input and process them manually."
 		end

	end
	puts LINE_SEPARATOR
end

main