#!/bin/bash
##
# Find use statements and needed classes in a file.

findUsesAndNeeds() {
    declare -p needs &>>/dev/null || return 1
    declare -p uses &>>/dev/null || return 1
    # shellcheck disable=SC2154
    declare -p namespace &>>/dev/null || return 1

    while read -r line; do
        [[ $line == namespace* ]] && check_uses='true'
        if [[ $line == @(class|interface|trait)* ]]; then
            check_uses='false' 
            check_needs='true'
            
            read -ra line_array <<<"$line"
            set -- "${line_array[@]}"
            while shift && [[ "$1" != @(extends|implements) ]]; do :; done;
            while shift && [[ -n $1 ]]; do 
                [[ $1 == 'implements' ]] && shift
                [[ $1 == \\* ]] || _set_needed_if_not_used "$1"
            done
        fi

        if $check_uses; then
            if [[ $line == use* ]]; then
                declare class_name="${line##*\\}"
                [[ $class_name == *as* ]] && class_name="${class_name##*as }"
                debug "Class name: $class_name"
                class_name="${class_name%%[^a-zA-Z]*}"
                uses["$class_name"]='used'
            fi
        fi

        if $check_needs; then
            if [[ $line == *function*([[:space:]])*([[:alnum:]_])\(* ]]; then
                _check_function_needs "$line"
                continue
            fi
            _check_needs "$line"
        fi
    done
}

_check_function_needs() {
    # Strip everything up until function name and argument declaration.
    declare line="${1#*function}" function_declaration="${1#*function}"

    # Collect the entire argument declaration
    while [[ $line != *'{'* ]] && read -r line; do
        function_declaration="$function_declaration $line"
    done

    declare -a words=()
    read -ra words <<<"$function_declaration"
    for i in "${!words[@]}"; do
        if [[ "${words[$i]}" =~ ^'$'[a-zA-Z_]+ ]]; then
            declare prev_word="${words[$((i-1))]}"
            if [[ $prev_word =~ ^([^\(]*\()?([A-Za-z]+)$ ]]; then
                declare class_name="${BASH_REMATCH[2]}"
                debugf 'Found parameter type "%s" for function "%s"\n' "$class_name" "$function_declaration"
                _set_needed_if_not_used "$class_name"
            fi
        fi
    done
    if [[ "$function_declaration" =~ \):[[:space:]]+([a-zA-Z]+) ]]; then
        declare class_name="${BASH_REMATCH[1]}"
        debugf 'Found return type "%s" for function "%s"\n' "$class_name" "$function_declaration"
        _set_needed_if_not_used "$class_name"
    fi
}

_check_needs() {
    declare line="$1" match=''
    if _line_matches "$line"; then
        declare class_name="${match//[^a-zA-Z]/}"

        debugf 'Extracted type "%s" from line "%s". Entire match: "%s"\n' "$class_name" "$line" "${BASH_REMATCH[0]}"
        _set_needed_if_not_used "$class_name"

        line="${line/"${BASH_REMATCH[0]/}"}"
        _check_needs "$line"
    fi
}

# shellcheck disable=SC2049 
_line_matches() {
    if [[ $line =~ 'new'[[:space:]]+([^\\][A-Za-z]+)\( ]] \
        || [[ $line =~ 'instanceof'[[:space:]]+([A-Za-z]+) ]] \
        || [[ $line =~ catch[[:space:]]*\(([A-Za-z]+) ]] \
        || [[ $line =~ \*[[:blank:]]*@([A-Z][a-zA-Z]*) ]]; then 
        match="${BASH_REMATCH[1]}"
        return $?
    elif [[ $line =~ @(var|param|return|throws)[[:space:]]+([A-Za-z]+) ]] \
        || [[ $line =~ (^|[\(\[\{[:blank:]])([A-Za-z]+)'::' ]]; then
        match="${BASH_REMATCH[2]}"
        return $?
    fi
    return 1
}

_set_needed_if_not_used() {
    declare class_name="$1"
    if [[ -z ${uses["$class_name"]} ]] \
        && [[ -z ${namespace["$class_name"]} ]] \
        && [[ "$class_name" != @(static|self|string|int|float|array|object|bool|mixed|parent|void) ]]; then
        needs["$class_name"]='needed'
    fi
}
