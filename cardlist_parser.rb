require 'csv'
require './anki_interface.rb'
require './jisho_interface.rb'

def main
	filename = ARGV[0]
	if !filename
		puts "Please pass in filename as argument"
		exit
	end

	puts "open #{filename}"
	CSV.foreach("#{filename}") do |row|
 		row.each do |word|
 			dictionary_result = search(word)[0]
 			puts dictionary_result.inspect
 		end
	end
end

main