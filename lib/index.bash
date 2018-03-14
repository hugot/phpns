#!/bin/bash
##
# Funtions that have to do with indexing a project

diffIndex() {
    (cd "$CACHE_DIR" && lsPhpRecursive "$CACHE_DIR") | findNonExistentFiles | (cd "$CACHE_DIR" && removeFiles)
    lsPhpRecursive | (cd "$CACHE_DIR" && findNonExistentFiles)
}

lsPhpRecursive() {
    find ./ -name '*.php' -not -empty -type f | grep -v '^./\(var\|.cache\|vendor/bin\)'
}

findNonExistentFiles() {
    while read -r file; do
        if ! [[ -f $file ]]; then
            echo "$file"
        fi
    done
}

removeFiles() {
    declare -i removed=0
    while read -r file; do
        rm "$file"
        ((removed++))
    done
    info "$removed files removed from index."
}

checkCache() {
    if ! [[ -d "$CACHE_DIR" ]]; then
        info "No cache dir found, indexing." >&2
        execute index
    fi
}

fillIndex() {
    declare -A files=()
    while IFS=':' read -ra line; do
        declare file="$CACHE_DIR/${line[0]}"
        declare dir="${file%/*}"

        [[ -d "$dir" ]] || mkdir -p "$dir"
        echo "${line[1]}" >> "$file"
        files["${line[0]}"]='indexed'
        if [[ $((${#files[@]}%500)) == 0 ]]; then
            info "indexed ${#files[@]} files."
        fi
    done
    
    info "Finished indexing. Indexed ${#files[@]} files." >&2
}
