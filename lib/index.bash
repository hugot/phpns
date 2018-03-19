#!/bin/bash
##
# Funtions that have to do with indexing a project

##
# This function outputs the difference between the files that are present in the
# index and the files that are present in the project directory. The output format is:
# +:NEW_FILE        (**Not in index but exists on disk**)
# -:DELETED_FILE    (**In index but does not exist on disk**)
##
diffIndex() {
    diff --unchanged-line-format='' --new-line-format='+:%L' --old-line-format='-:%L' \
        <(sort -u < "$INDEXED" | sed '/^[[:blank:]]*$/d') \
        <(find ./ -name '*.php' -type f | sed 's!^\./\|^./\(var\|.cache\|vendor/bin\)/.\+$!!g; /^[[:blank:]]*$/d' | sort)
}

##
# This function reads the output of a grep command with the option -H or
# --with-filename enabled. The lines containing class and namespace declarations
# will be parsed and added to the index.
#
# shellcheck disable=SC2153
##
fillIndex() {
    [[ -n $CACHE_DIR ]]            || return 1
    [[ -n $CLASSES ]]              || return 1
    [[ -n $NAMESPACES ]]           || return 1
    [[ -n $USES ]]                 || return 1
    [[ -n $USES_LOOKUP ]]          || return 1
    [[ -n $FILE_PATHS ]]           || return 1
    [[ -n $NAMESPACE_FILE_PATHS ]] || return 1
    [[ -n $INDEXED ]]              || return 1

    [[ -d $CACHE_DIR ]] || mkdir -p "$CACHE_DIR"

    # Clean up index files if not diffing.
    echo > "$NAMESPACES"
    echo > "$CLASSES"
    echo > "$USES"
    echo > "$USES_LOOKUP"
    echo > "$FILE_PATHS"
    echo > "$USES_LOOKUP_OWN"
    echo > "$NAMESPACE_FILE_PATHS"
    echo > "$INDEXED"

    declare -A namespaces=() classes=()
    while IFS=':' read -ra line; do
        declare file="${line[0]}"

        # Save the namespace or class to add to the FQN cache later on.
        if [[ "${line[1]}" =~ (class|trait|interface)[[:blank:]]+([A-Za-z_]+) ]]; then
            classes[$file]="${BASH_REMATCH[2]}"
        elif [[ "${line[1]}" =~ namespace[[:blank:]]+([A-Za-z_\\]+) ]]; then
            namespaces[$file]="${BASH_REMATCH[1]}"
        else 
            debugf 'No class or namespace found in line "%s"' "${line[0]}"
        fi

        # Add filename to file with indexed filenames. This is required
        # for diffing the index.
        echo "$file" >> "$INDEXED"

        if [[ $((++lines%500)) -eq 0 ]]; then
            info "indexed $lines lines."
        fi
    done

    # Fill up the index
    declare -i uses=0
    for file in "${!classes[@]}"; do
        declare namespace="${namespaces[$file]}"
        declare class="${classes[$file]}"

        if [[ -z $class ]]; then
            debugf 'Class is missing for file "%s"\n' "$file"
            debugf 'Namespace: "%s"\n' "$namespace"
            continue
        fi

        ((uses++))
        [[ $((uses%500)) -eq 0 ]] && info "Found FQN's for $uses classes."

        echo "$namespace"                >> "$NAMESPACES"
        echo "$class"                    >> "$CLASSES"
        echo "$namespace\\$class"        >> "$USES"
        echo "$class:$namespace\\$class" >> "$USES_LOOKUP"
        echo "$file:$namespace\\$class"  >> "$FILE_PATHS"
        echo "$file:$namespace"          >> "$NAMESPACE_FILE_PATHS"

        [[ $file != 'vendor/'* ]] && echo "$class:$namespace\\$class" >> "$USES_LOOKUP_OWN"

    done

    # This keeps the index of class names unique, so that completing class names takes as little
    # time as possible.
    # Use echo and a subshell here to prevent changing the file before the command is done.
    # shellcheck disable=SC2005
    echo "$(sort -u < "$CLASSES")" > "$CLASSES"

    # Ditto for the namespaces index
    # shellcheck disable=SC2005
    echo "$(sort -u < "$NAMESPACES")" > "$NAMESPACES"
    
    info "Finished indexing. Indexed ${lines} lines and found FQN's for $uses classes." >&2
}

checkCache() {
    if ! [[ -d "$CACHE_DIR" ]]; then
        info "No cache dir found, indexing." >&2
        execute index
    fi
}
