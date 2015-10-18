# encoding: utf-8
require 'colorize'
DEBUG_OUT = true

def warning(string)
	puts ("Warning: "+string).light_red
end

def error(string)
	puts ("Error: "+string).red
end

def debug(string)
	puts "\t"+string if DEBUG_OUT == true
end