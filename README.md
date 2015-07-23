# flashcard-builder

Installation
===
The only thing that's really necessary is to run Bundler if you want to detect cases where card definitions include the romaji for the word.
```
cd flashcard-builder
bundle
```

Testing & Usage
==
Functionality is very minimal - it just does what I need it to do. Adjusting the ruby to produce cards in another format shouldn't be particularly difficult, but for out of the box usage, simply run cardlist_parser.rb on a valid CSV of Japanese vocabulary. Like so:
```
ruby cardlist_parser.rb example_input.txt 
```
Output, by default, is a CSV in the form
```
<Expression>, <Meaning>, <Reading>, <Example>
```
Note that examples are currently left blank, as it seems jisho.org does not have an API for the sentence search yet. 

Importing to Anki
==
From Anki's _desktop client_, go to File->Import. The rest is pretty self explanatory, just make sure that the fields are set up properly. 


Known Bugs
==
Definitions with quotes in them cause problems.  There's code to escape quotes inside the strings, but it doesn't seem to be working properly. 


