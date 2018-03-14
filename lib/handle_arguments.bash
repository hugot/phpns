##
# Functions for parameter parsing

# Enum for config
declare -gri CLASS_NAME=0
declare -gri PREFER_OWN=1
declare -gri AUTO_PICK=2
declare -gri STDOUT=3
declare -gri JSON=4
declare -gri BARE=5
declare -gri WORD=6
declare -gri EXPAND_CLASSES=7
declare -gri NO_CLASSES=8
declare -gri NAMESPACE=9
declare -gri CLASS_PATH=10
declare -gri INDEX_DIFF=11

handleArguments() {
    declare -p CONFIG &>>/dev/null || return 1
    declare command="$1"
    shift
    case "$command" in
        find-use)
            _handle_find_use_arguments "$@" || return $?
            ;;
        fix-uses)
            _handle_fix_uses_arguments "$@" || return $?
            ;;
        complete)
            _handle_complete_arguments "$@" || return $?
            ;;
        index)
            _handle_index_arguments "$@" || return $?
            ;;
        classes-in-namespace)
            _handle_classes_in_namespace_arguments "$@" || return $?
            ;;
        filepath)
            _handle_filepath_arguments "$@" || return $?
            ;;
        *)
            printf 'handleArguments (line %s): Unknown command "%s" passed.\n' "$(caller)" "$command">&2
            return 1
            ;;
    esac
}

_handle_filepath_arguments() {
    declare arg="$1"
    while shift; do
        case "$arg" in
            -s | --silent)
                INFO=0
                ;;
            --*)
                printf 'Unknown option: "%s"\n' "${arg}" >&2
                return 1
                ;;
            -*)
                if [[ ${#arg} -gt 2 ]]; then
                    declare -i i=1
                    while [[ $i -lt ${#arg} ]]; do
                        _handle_filepath_arguments "-${arg:$i:1}"
                        ((i++))
                    done
                else
                    printf 'Unknown option: "%s"\n' "${arg}" >&2
                    return 1
                fi
                ;;
            '')
                :
                ;;
            *)
                if [[ -n ${CONFIG[$CLASS_PATH]} ]]; then
                    printf 'Unexpected argument: "%s"\n' "$arg" >&2
                    return 1
                fi
                CONFIG[$CLASS_PATH]="$arg"
        esac
        arg="$1"
    done
}

_handle_classes_in_namespace_arguments() {
    declare arg="$1"
    while shift; do
        case "$arg" in
            -s | --silent)
                INFO=0
                ;;
            --*)
                printf 'Unknown option: "%s"\n' "${arg}" >&2
                return 1
                ;;
            -*)
                if [[ ${#arg} -gt 2 ]]; then
                    declare -i i=1
                    while [[ $i -lt ${#arg} ]]; do
                        _handle_classes_in_namespace_arguments "-${arg:$i:1}"
                        ((i++))
                    done
                else
                    printf 'Unknown option: "%s"\n' "${arg}" >&2
                    return 1
                fi
                ;;
            '')
                :
                ;;
            *)
                if [[ -n ${CONFIG[$NAMESPACE]} ]]; then
                    printf 'Unexpected argument: "%s"\n' "$arg" >&2
                    return 1
                fi
                CONFIG[$NAMESPACE]="$arg"
        esac
        arg="$1"
    done
}

_handle_index_arguments() {
    declare arg="$1"
    while shift; do
        case "$arg" in
            -s | --silent)
                INFO=0
                ;;
            -d | --diff)
                CONFIG[$INDEX_DIFF]='--diff'
                ;;
            -*)
                if [[ ${#arg} -gt 2 ]]; then
                    declare -i i=1
                    while [[ $i -lt ${#arg} ]]; do
                        _handle_index_arguments "-${arg:$i:1}"
                        ((i++))
                    done
                else
                    printf 'Unknown option: "%s"\n' "${arg}" >&2
                    return 1
                fi
                ;;
            *)
                printf 'Unexpected argument: "%s"\n' "$arg" >&2
                return 1
                ;;
        esac
        arg="$1"
    done
}

_handle_fix_uses_arguments() {
    declare arg="$1"
    while shift; do
        case "$arg" in
            -s | --silent)
                INFO=0
                ;;
            -p | --prefer-own)
                CONFIG[$PREFER_OWN]='--prefer-own'
                ;;
            -a | --auto-pick)
                CONFIG[$AUTO_PICK]='--auto-pick'
                ;;
            -o | --stdout)
                CONFIG[$STDOUT]='--stdout'
                INFO=0
                ;;
            -j | --json)
                CONFIG[$STDOUT]='--stdout'
                CONFIG[$JSON]='--json'
                ;;
            --*)
                printf 'Unknown option: "%s"\n' "${arg}" >&2
                return 1
                ;;
            -*)
                if [[ ${#arg} -gt 2 ]]; then
                    declare -i i=1
                    while [[ $i -lt ${#arg} ]]; do
                        _handle_fix_uses_arguments "-${arg:$i:1}"
                        ((i++))
                    done
                else
                    printf 'Unknown option: "%s"\n' "${arg}" >&2
                    return 1
                fi
                ;;
            '')
                :
                ;;
            *)
                if [[ -n ${CONFIG[$CLASS_NAME]} ]]; then
                    printf 'Unexpected argument: "%s"\n' "$arg" >&2
                    return 1
                fi
                CONFIG[$CLASS_NAME]="$arg"
        esac
        arg="$1"
    done
}

# shellcheck disable=SC2034
_handle_find_use_arguments() {
    declare arg="$1"
    while shift; do
        case "$arg" in
            -s | --silent)
                INFO=0
                ;;
            -b | --bare)
                CONFIG[$BARE]='--bare'
                ;;
            -p | --prefer-own)
                CONFIG[$PREFER_OWN]='--prefer-own'
                ;;
            -a | --auto-pick)
                CONFIG[$AUTO_PICK]='--auto-pick'
                ;; 
            -j | --json) CONFIG[$STDOUT]='--stdout'
                CONFIG[$JSON]='--json'
                INFO=0
                ;;
            --*)
                printf 'Unknown option: "%s"\n' "${arg}" >&2
                return 1
                ;;
            -*)
                if [[ ${#arg} -gt 2 ]]; then
                    declare -i i=1
                    while [[ $i -lt ${#arg} ]]; do
                        _handle_find_use_arguments "-${arg:$i:1}"
                        ((i++))
                    done
                else
                    printf 'Unknown option: "%s"\n' "${arg}" >&2
                    return 1
                fi
                ;;
            '')
                :
                ;;
            *)
                if [[ -n ${CONFIG[$CLASS_NAME]} ]]; then
                    printf 'Unexpected argument: "%s"\n' "$arg" >&2
                    return 1
                fi
                CONFIG[$CLASS_NAME]="$arg"
        esac
        arg="$1"
    done
}

_handle_complete_arguments() {
    declare arg="$1"
    while shift; do
        case "$arg" in
            -e | --expand-classes)
                CONFIG[$EXPAND_CLASSES]='--expand-classes'
                ;;
            -n | --no-classes)
                CONFIG[$NO_CLASSES]='--no-classes'
                ;;
            -s | --silent)
                INFO=0
                ;;
            --*)
                printf 'Unknown option: "%s"\n' "${arg}" >&2
                return 1
                ;;
            -*)
                if [[ ${#arg} -gt 2 ]]; then
                    declare -i i=1
                    while [[ $i -lt ${#arg} ]]; do
                        _handle_complete_arguments "-${arg:$i:1}"
                        ((i++))
                    done
                else
                    printf 'Unknown option: "%s"\n' "${arg}" >&2
                    return 1
                fi
                ;;
            '')
                :
                ;;
            *)
                if [[ -n ${CONFIG[$WORD]} ]]; then
                    printf 'Unexpected argument: "%s"\n' "$arg" >&2
                    return 1
                fi
                CONFIG[$WORD]="$arg"
        esac
        arg="$1"
    done
}

