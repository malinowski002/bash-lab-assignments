#!/bin/bash

set -eu

# czy podano argumenty
if [ ! $# -eq 2 ]
  then
    echo "Brak podanych 2 argumentow!"
    exit 1
fi

# pobieranie argumentów
DIR_1=$1
DIR_2=$2

# info o katalogu 1
if [[ -d $DIR_1 ]]
  then
  echo "Plik 1 to katalog"
elif [[ -f $DIR_1 ]]
  then
  echo "Plik 1 to plik regularny"
elif [[ -L $DIR_1 ]]
  then
  echo "Plik 1 to dowiazanie symboliczne"
fi

ALL_FILES=$(ls "$DIR_1")

# tworzenie dowiazan symbolicznych
for FILE in $ALL_FILES
  do
    ln -s "../$DIR_1/$FILE" "$DIR_2/$FILE"
done

ALL_SYMLINKS=$(ls "$DIR_2")

# formatowanie nazw plikow
for FILE in $ALL_SYMLINKS
  do
  # nzwa
  FILENAME=$(basename -- "$FILE")
  # nazwa bez rozszerzenia
  FILENAME_NO_EXTENSION="${FILENAME%.*}"
  # rozszerzenie
  EXTENSION="${FILENAME##*.}"
  # formatowanie liter
  UPP_FILENAME=$(echo "$FILENAME_NO_EXTENSION" | tr '[:lower:]' '[:upper:]')
  # dodawanie _ln
  NEW_FILENAME="${UPP_FILENAME}_ln.$EXTENSION"
  # faktyczna zmiana nazwy
  mv "$DIR_2/$FILE" "$DIR_2/$NEW_FILENAME"
done