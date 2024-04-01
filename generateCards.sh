#!/bin/bash

sourcefile=flashcards.txt

while getopts "f:" opt; do
    case $opt in
        f) sourcefile="$OPTARG"
        ;;
        \?) echo "Invalid option -$OPTARG" >&2
        ;;
    esac
done

#the first line of the output is the column names. store them in an array
IFS="|" read -r -a columnNames <<< $(head -1 $sourcefile)

#store each line of the output in an array
IFS=$'\n' read -d '' -r -a rows <<< $(tail -n +2 $sourcefile)

#make sure completeCard.txt is empty
echo "" > completeCard.tex

#In the file basicTemplate.txt, replace {{front}} with the front of the card
#and replace {{back}} with the back of the card
#store the result in a variable
for row in "${rows[@]}"; do
    IFS="|" read -r -a card <<< $row
    sed "s|{{front}}|${card[0]}|g;s|{{back}}|${card[1]}|g;s|{{topic}}|${card[2]}|g;s|{{num}}|${card[3]}|g" basicTemplate.tex >> completeCard.tex
done

dummy=$(pdflatex flashcards.tex -o flashcards.pdf)

#if last command was successful remove unnecessary files otherwise show the error
if [ $? -eq 0 ]; then
    rm flashcards.log flashcards.aux completeCard.tex
else
    echo "Error: ${dummy}"
fi