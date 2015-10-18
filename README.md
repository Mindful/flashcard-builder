# flashcard-builder

Installation
===
Just run Bundler. 
```
cd flashcard-builder
bundle
```

Testing & Usage
==
Functionality is very minimal - it just does what I need it to do right now. Adjusting the ruby to produce cards in another format shouldn't be particularly difficult, but for out of the box usage, simply run cardlist_parser.rb on a valid CSV of Japanese vocabulary. Like so:
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
- Definitions with quotes in them can cause problems.  There's code to escape quotes inside the strings, but it doesn't seem to be working properly. 
- Right now, we're a little bit overzealous about reporting mismatches in searches. It's not uncommon to get warnings about words that are perfectly fine, especially in cases where jisho.org's results simply include more kanji than the input, but the input is not entirely hiragana.
- Certain words, where there is overlap bewteen the kana contents of the okurigana and reading, cause problems. After several attempted rewrites I am convinced that this is fairly unavoidable, as a side effect of the fact that with only the information we get from jisho.org's API there are simply some cases where there is no way to distinguish between okurigana and furigana in the reading. That said, the app should work properly for the _vast majority_ of words. On the off chance something goes wrong, the app will also do its best to alert you, although it can only catch certain cases (where premature stopping has caused there to be characters left over in the reading string). __Realistically, with current optimizations and prevention of issues at the end of the string, problems should only occur in cases where okurigana between two kanji is identical to, or shares kana with, the reading of the previous kanji.__


