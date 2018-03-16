#!/bin/bash
##
# Funtions that have to do with indexing a project

diffIndex() {
    (cd "$TREE_DIR" && lsPhpRecursive "$TREE_DIR") | findNonExistentFiles | (cd "$TREE_DIR" && removeFiles)
    lsPhpRecursive | (cd "$TREE_DIR" && findNonExistentFiles)
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
    if ! [[ -d "$TREE_DIR" ]]; then
        info "No cache dir found, indexing." >&2
        execute index
    fi
}

fillIndex() {
    [[ -n $TREE_DIR ]] || return 1
    [[ -n $CACHE_DIR ]] || return 1
    [[ -n $CLASSES ]] || return 1
    [[ -n $NAMESPACES ]] || return 1

    while IFS=':' read -ra line; do
        declare file="$TREE_DIR/${line[0]}"
        declare dir="${file%/*}"

        [[ -d "$dir" ]] || mkdir -p "$dir"
        echo "${line[1]}" >> "$file"
        if [[ $((++lines%500)) -eq 0 ]]; then
            info "indexed $lines lines."
        fi
    done

    # Look up all namespaces for completion cache
    grep -rPho '(?<=namespace) [A-Za-z_\\]+' "$TREE_DIR" | sed 's/^[[:blank:]]\+//g' | sort -u > "$NAMESPACES"

    # Look up all classes for completion cache
    grep -rPho '(?<=class) [A-Za-z_]+' "$TREE_DIR" | sed 's/^[[:blank:]]\+//g' | sort -u > "$CLASSES"
    
    info "Finished indexing. Indexed ${lines} lines." >&2
}
