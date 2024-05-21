#!/bin/bash -eu

function print_help () {
    echo "This script allows to search over movies database"
    echo -e "-d DIRECTORY\n\tDirectory with files describing movies"
    echo -e "-a ACTOR\n\tSearch movies that this ACTOR played in"
    echo -e "-t QUERY\n\tSearch movies with given QUERY in title"
    echo -e "-f FILENAME\n\tSaves results to file (default: results.txt)"
    echo -e "-x\n\tPrints results in XML format"
    echo -e "-h\n\tPrints this help message"
}

function print_error () {
    echo -e "\e[31m\033[1m${*}\033[0m" >&2
}

function get_movies_list () {
    local -r MOVIES_DIR=${1}
    local -r MOVIES_LIST=$(cd "${MOVIES_DIR}" && realpath ./*)
    echo "${MOVIES_LIST}"
}

function query_title () {
    # Returns list of movies from ${1} with ${2} in title slot
    local -r MOVIES_LIST=${1}
    local -r QUERY=${2}

    local RESULTS_LIST=()
    for MOVIE_FILE in ${MOVIES_LIST}; do
        if grep "| Title" "${MOVIE_FILE}" | grep -q "${QUERY}"; then
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}

function query_actor () {
    # Returns list of movies from ${1} with ${2} in actor slot
    local -r MOVIES_LIST=${1}
    local -r QUERY=${2}

    local RESULTS_LIST=()
    for MOVIE_FILE in ${MOVIES_LIST}; do
        if grep "| Actors" "${MOVIE_FILE}" | grep -q "${QUERY}"; then
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}

function query_plot () {
    # Returns list of movies from ${1} with ${2} based on plot regex
    # if {3} is TRUE, ignore letter case
    local -r MOVIES_LIST=${1}
    local -r REGEX=${2}
    local -r IGNORE_CASE=${3}

    if [[ "$IGNORE_CASE" == "true" ]]; then
        shopt -s nocasematch
    fi

    local RESULTS_LIST=()

    for MOVIE_FILE in ${MOVIES_LIST}; do
        if [[ $(< "$MOVIE_FILE") =~ $REGEX ]]; then
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}

function print_movies () {
    local -r MOVIES_LIST=${1}
    local -r OUTPUT_FORMAT=${2}

    for MOVIE_FILE in ${MOVIES_LIST}; do
        if [[ "${OUTPUT_FORMAT}" == "xml" ]]; then
            print_xml_format "${MOVIE_FILE}"
        else
            cat "${MOVIE_FILE}"
        fi
    done
}

function print_xml_format () {
    local -r FILENAME=${1}

    local TEMP
    TEMP=$(cat "${FILENAME}")

    # TODO: replace first line of equals signs

    # TODO: change 'Author:' into <Author>
    # TODO: change others too

    # append tag after each line
    TEMP=$(echo "${TEMP}" | sed -r 's/([A-Za-z]+).*/\0<\/\1>/')

    # replace the last line with </movie>
    TEMP=$(echo "${TEMP}" | sed '$s/===*/<\/movie>/')

    echo "${TEMP}"
}

MOVIES_DIR=""
IGNORE_CASE="FALSE"

while getopts ":hd:t:a:f:xp:i" OPT; do
    case ${OPT} in
        h)
            print_help
            exit 0
            ;;
        d)
            MOVIES_DIR=${OPTARG}
            ;;
        t)
            SEARCHING_TITLE=true
            QUERY_TITLE=${OPTARG}
            ;;
        f)
            FILE_4_SAVING_RESULTS=${OPTARG}
            ;;
        a)
            SEARCHING_ACTOR=true
            QUERY_ACTOR=${OPTARG}
            ;;
        p)
            SEARCHING_PLOT=true
            QUERY_PLOT=${OPTARG}
            ;;
        i)
            IGNORE_CASE=true
            # QUERY_PLOT=${OPTARG}
            ;;
        x)
            OUTPUT_FORMAT="xml"
            ;;
        \?)
            print_error "ERROR: Invalid option: -${OPTARG}"
            exit 1
            ;;
    esac
done

if [ -z "$MOVIES_DIR" ]; then
    print_error "Nie podano opcji -d (katalogu)"
    exit 1
fi

if ! [ -d "$MOVIES_DIR" ]; then
    print_error "To nie katalog!"
    exit 1
fi

MOVIES_LIST=$(get_movies_list "${MOVIES_DIR}")

if ${SEARCHING_TITLE:-false}; then
    MOVIES_LIST=$(query_title "${MOVIES_LIST}" "${QUERY_TITLE}")
fi

if ${SEARCHING_ACTOR:-false}; then
    MOVIES_LIST=$(query_actor "${MOVIES_LIST}" "${QUERY_ACTOR}")
fi

if ${SEARCHING_PLOT:-false}; then
    MOVIES_LIST=$(query_plot "${MOVIES_LIST}" "${QUERY_PLOT}" "${IGNORE_CASE}")
fi

if [[ "${#MOVIES_LIST}" -lt 1 ]]; then
    echo "Found 0 movies :-("
    exit 0
fi

if [[ "${FILE_4_SAVING_RESULTS:-}" == "" ]]; then
    print_movies "${MOVIES_LIST}" "${OUTPUT_FORMAT:-raw}"
else
    if ! [[ "$FILE_4_SAVING_RESULTS" =~ \.txt$ ]]; then
        FILE_4_SAVING_RESULTS="${FILE_4_SAVING_RESULTS}.txt"
    fi
    print_movies "${MOVIES_LIST}" "${OUTPUT_FORMAT:-raw}" | tee "${FILE_4_SAVING_RESULTS}"
fi

# ./movies.sh -d <directory> [-t <title>] [-a <actor>] [-f <output_file>] [-x]

# 2.0 shellcheck
# 1.0 -d directory check
# 1.0 -f .txt adding
# 1.0 plot regex