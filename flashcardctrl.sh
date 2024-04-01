#!/bin/bash

function displayUsage() {
    echo -e "Flashcardctrl: Store, retrieve, and generate flashcards as a pdf."
    echo -e "Usage: $0 [-s] [-f <front>] [-b <back>] [-t <topic>] [-g] [-h]\n"
    echo -e "Basic usage: add a flashcard to the database: $0 -f <front> -b <back> -t <topic>"
    echo -e "Search the database: $0 -s -f <front> -b <back> -t <topic>"
    echo -e "\tIf front, back, or topic are optional. If they are not set, they will be set to empty strings."
    echo -e "\tOmitting all will result in all flashcards being returned."
    echo -e "Generate flashcards: $0 -g -f <front> -b <back> -t <topic>"
    echo -e "\tUse with -s to generate only the flashcards that match the search."
    echo -e "\tExample: $0 -g -s -f <front> -b <back> -t <topic>"
    echo -e "-h: display this help message"
}

search=false
generate=false
#get the options
while getopts ":sf:b:t:gh" opt; do
  case $opt in
    s) search=true
    ;;
    f) front="$OPTARG"
    ;;
    b) back="$OPTARG"
    ;;
    t) topic="$OPTARG"
    ;;
    g) generate="true"
    ;;
    h) displayUsage
    exit 0
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    displayUsage
    exit 1
    ;;
  esac
done

base_path=$(systemd-path user-shared)
db_path="$base_path/flashcards/"
db=$db_path"flashcards.db"
tempfile=$(mktemp)
results=""

#if flashcards.db doesn't exist, create it
if [ ! -f "$db_path/flashcards.db" ]; then
    echo "The flashcard database does not exist. Creating it now."
    #create the path
    mkdir -p $db_path
    sqlite3 $db
    
    sqlite3 $db "create table flashcards (id integer primary key autoincrement, front text, back text, topic text);"
fi



#if front, back, or topic are set and search is false, insert them into the db
if [ -n "$front" ] && [ -n "$back" ] && [ -n "$topic" ] && [ "$search" = "false" ]; then
    #if front, back, or topic are not set, set them to empty strings
    if [ -z "$front" ]; then
        front=""
    fi
    if [ -z "$back" ]; then
        back=""
    fi
    if [ -z "$topic" ]; then
        topic=""
    fi
    sqlite3 $db "insert into flashcards (front, back, topic) values(\"$front\", \"$back\", \"$topic\");"

    echo "Flashcard inserted into database."
    echo "$(sqlite3 $db 'select * from flashcards order by id desc limit 1;')"
fi

#if search is true, search the db
if [ "$search" = "true" ]; then
    echo "Searching database for: $topic"
    results=$(sqlite3 -header $db "select front, back, topic, id from flashcards where front like '%$front%' and back like '%$back%' and topic like '%$topic%';")
    echo "$results"
    echo "$results" > $tempfile
fi

#if generate is set, generate the cards
if [ "$generate" = "true" ]; then
    #if results is empty, search the db for all entries
    if [ -z "$results" ]; then
        results=$(sqlite3 -header $db "select front, back, topic, id from flashcards;")
        echo "$results" > $tempfile
    fi
    bash generateCards.sh -f $tempfile
fi

rm $tempfile