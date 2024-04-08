#!/bin/bash

set -eu

# sprawdzanie czy parametr został podany
if [ $# -eq 0 ]
  then
    echo "Brak podanego argumentu!"
    exit 1
fi

# pobieranie parametru
GIVEN_DIR=$1

# sprawdzanie czy istnieje katalog
if [[ ! -d "$GIVEN_DIR" ]]; then
    echo "Katalog $GIVEN_DIR nie istnieje"
    exit 1
fi

# iterowanie po plikach
ALL_FILES=$(ls "$GIVEN_DIR")

for FILE in $ALL_FILES
    do
    # jezeli plik regularny .bak
    if [[ -f $GIVEN_DIR/$FILE ]]
    then
        if [[ $FILE == *.bak ]]
        then
            chmod a-w "$GIVEN_DIR/$FILE"
        elif [[ $FILE == *.exe ]]
        then
            chmod 111 "$GIVEN_DIR/$FILE"
            chmod u+s
            chmod g+s
        fi
    fi
    # jezeli katalog .bak
    if [[ -d $GIVEN_DIR/$FILE ]]
    then   
        if [[ $FILE == *.bak ]]
        then
            chmod 213 "$GIVEN_DIR/$FILE"
            # user group others
            # RWX  RWX   RWX
            # 010  001   011
        # jezeli katalog .tmp
        elif [[ $FILE == *.tmp ]]
        then
            chmod -R 700 "$GIVEN_DIR/$FILE"
        fi
    fi
    # jezeli (kazdy) plik .txt
    if [[ $FILE == *.txt ]]
    then
        chmod 241 "$GIVEN_DIR/$FILE"
        # user group others
        # RWX  RWX   RWX
        # 010  100   001
    fi
done