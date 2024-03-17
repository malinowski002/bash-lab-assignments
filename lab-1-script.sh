#!/bin/bash

# punkt 1 - przyjmowanie argumentów z wartościami domyślnymi
SOURCE_DIR=${1:-lab_uno}
RM_LIST=${2:-2remove}
TARGET_DIR=${3:-bakap}

# punkt 2 - tworzenie katalogu, jeśli nie istnieje
if [[ ! -d $SOURCE_DIR ]]
then
    mkdir "$SOURCE_DIR"
fi

# punkt 3 - usuwanie plików o nazwach zczytanych z pliku RM_LIST
FILE_CONTENT=$(cat "$SOURCE_DIR/$RM_LIST")

for ITEM in $FILE_CONTENT
    do
    if [[ -f $SOURCE_DIR/$ITEM ]]
    then
        rm "$SOURCE_DIR/$ITEM"
    elif [[ -d $SOURCE_DIR/$ITEM ]]
    then
        rm -rf "$SOURCE_DIR/$ITEM"
    fi
done

# punkt 4 - przenoszenie plików, które nie zostały usunięte
FILE_SURVIVORS=$(ls "$SOURCE_DIR")

for FILE in $FILE_SURVIVORS
    do
    # sprawdź czy istnieje katalog, utwórz jeśli nie
        if [[ ! -d $TARGET_DIR ]]
        then
            mkdir "$TARGET_DIR"
        fi
    # sprawdź czy plik
    if [[ -f $SOURCE_DIR/$FILE ]]
    then
        mv "$SOURCE_DIR/$FILE" "$TARGET_DIR"
    fi
    # sprawdź czy katalog
    if [[ -d $SOURCE_DIR/$FILE ]]
    then
        cp -r "$SOURCE_DIR/$FILE" "$TARGET_DIR"
    fi
done

# punkt 5 - sprawdzenie czy coś jeszcze zostało
FILE_COUNT=$(ls "$SOURCE_DIR" | wc -l)

if [[ $FILE_COUNT -ge 2 ]]
then
    echo "Zostały co najmniej 2 pliki"
elif [[ $FILE_COUNT -gt 4 ]]
then
    echo "Zostało więcej niz 4 pliki"
elif [[ $FILE_COUNT -lt 4 && $FILE_COUNT -ge 2 ]]
then
    echo "Mniej niz 4 ale co najmniej 2 pliki"
elif [[ $FILE_COUNT -eq 0 ]]
then
    echo "Nie zostały zadne pliki"
fi

# punkt 6 - pakowanie TARGET_DIR do archiwum
DATE=$(date '+%Y-%m-%d')

zip -r "bakap_$DATE.zip" "$TARGET_DIR"