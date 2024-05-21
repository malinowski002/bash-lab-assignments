######### fakaping.sh #########
#1 stdout do nicości, sortowanie błędów

./fakaping.sh > /dev/null | sort 

#2 unikalne errory z "permission denied" na konsolę i do pliku

grep -i "Permission denied" ./fakaping.sh | sort -u | tee denied.log

######### access_log #########
#1 znalezienie 10 unikalnych IP

grep  -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" access_log | sort -u | head -n 10

#2 znalezienie unikalnych zapytań DELETE
grep -E "\"DELETE \/" access_log | sort -u

########## groovies ##########
#1 usuwanie linijek z 'Help docs:'

FILES=$(ls groovies)
for FILE in $FILES
    do
    sed -ie "/.*Help docs:.*/d" "groovies/$FILE"
done

#2 zamiana $HEADERS$ na /temat/
FILES=$(ls groovies)
for FILE in $FILES
    do
    sed -i -e "s/\$HEADER\$/\/temat\//g" "groovies/$FILE"
done