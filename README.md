# Flashcards
Flashcards is a utility for storing, searching, and generating pdf copies of flashcards.

## Requirements
* pdflatex
* elzcards and geometry libraries

## Usage
Adding a card: Run with the `-f`, `-b`, or `-t` to add a new card and set the front, back, and topic of the card.
For example:
```
$> ./flashcardctrl.sh -f "The Front" -b "The Back" -t "The Topic"
```

Searching for cards: Run with `-s` and optionally `-f`, `-b`, or `-t`. Running `-s` by itself will search return every card in the database. Use `-f`, `-b`, or `-t` to narrow the search.

Generating cards: Run with `-g` to generate the cards. This will generate every card returned by `-s`. If `-s` is not used, `-g` will generate every card in the database.