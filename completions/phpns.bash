_phpns_complete() { 
    declare word="${COMP_WORDS[COMP_CWORD]}";
    case "${COMP_WORDS[1]}" in 
        cmp |complete)
            __phpns_complete_complete
            ;;
        fxu | fix-uses)
            __phpns_complete_fix_uses
            ;;
        fu | find-use)
            __phpns_complete_find_use
            ;;
        cns | classes-in-namespace)
            __phpns_complete_classes_in_namespace
            ;;
        fp | filepath)
            __phpns_complete_filepath
            ;;
        i | index)
            __phpns_complete_index
            ;;
        "${COMP_WORDS[COMP_CWORD]}")
            declare -a commands=(
            'ns'  'namespace'
            'i'   'index'
            'fu'  'find-use '
            'fxu' 'fix-uses'
            'cns' 'classes-in-namespace'
            'cmp' 'complete'
            'fp'  'filepath'
            'help' 
            )
            COMPREPLY=($(compgen -W "${commands[*]}" "${COMP_WORDS[COMP_CWORD]}"))
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

__phpns_complete_filepath() {
    declare word="${COMP_WORDS[COMP_CWORD]}"
    case "$word" in
        -[^-] | -)
            COMPREPLY=($(compgen -P '-' -W 's' "${word/-/}"))
            ;;
        --*)
            COMPREPLY=($(compgen -P '--' -W 'silent' "${word/--/}"))
            ;;
        *)
            __phpns_complete_expand_classes
            ;;
    esac
}

__phpns_complete_index() {
    declare word="${COMP_WORDS[COMP_CWORD]}"
    case "$word" in
        -[^-] | -)
            COMPREPLY=($(compgen -P '-' -W 'N s d' "${word/-/}"))
            ;;
        --*)
            COMPREPLY=($(compgen -P '--' -W 'new silent diff' "${word/--/}"))
            ;;
    esac
}

__phpns_complete_complete() {
    declare word="${COMP_WORDS[COMP_CWORD]}"
    case "$word" in
        -[^-] | -)
            COMPREPLY=($(compgen -P '-' -W 's e n c' "${word/-/}"))
            ;;
        --*)
            COMPREPLY=($(compgen -P '--' -W 'silent expand-classes no-classes complete-classes' "${word/--/}"))
            ;;
        *)
            __phpns_complete_expand_classes
            ;;
    esac
}

__phpns_complete_fix_uses() {
    declare word="${COMP_WORDS[COMP_CWORD]}"
    case "$word" in 
        -[^-] | -)
            COMPREPLY=($(compgen -P '-' -W 's p a j o' "${word/-/}"))
            ;;
        --*)
            COMPREPLY=($(compgen -P '--' -W 'silent prefer-own auto-pick json stdout' "${word/--/}"))
            ;;
        *)
            COMPREPLY=("$word")
            ;;
    esac
}

__phpns_complete_find_use() {
    declare word="${COMP_WORDS[COMP_CWORD]}"
    case "$word" in 
        -[^-] | -)
            COMPREPLY=($(compgen -P '-' -W 's b p a j' "${word/-/}"))
            ;;
        --*)
            COMPREPLY=($(compgen -P '--' -W 'silent bare prefer-own auto-pick json' "${word/--/}"))
            ;;
        *)
            COMPREPLY=("$word")
            ;;
    esac
}

__phpns_complete_classes_in_namespace() {
    declare word="${COMP_WORDS[COMP_CWORD]}"
    case "$word" in 
        -*)
            COMPREPLY=()
            ;;
        *)
            __phpns_complete_namespace_FQN
            ;;
    esac
}

##
# Complete FQN's
##
__phpns_complete_FQN() {
    declare word="${COMP_WORDS[COMP_CWORD]}";
    [[ -z $PHPNS_COMP_OPT ]] && PHPNS_COMP_OPT='-s'

    if [[ $word == "'"* ]]; then
        word="${word//"'"/}"
        COMPREPLY=($(phpns cmp "$PHPNS_COMP_OPT" "${word//\\\\/\\}" | while read -r line; do echo "'$line'"; done))
    elif [[ $word == '"' ]]; then
        word="${word//'"'/}"
        COMPREPLY=($(phpns cmp "$PHPNS_COMP_OPT" "${word//\\\\/\\}" | while read -r line; do echo "\"${line//\\/\\\\}\""; done))
    else
        COMPREPLY=($(phpns cmp "$PHPNS_COMP_OPT" "${word//\\\\/\\}" | while read -r line; do echo "${line//\\/\\\\}"; done))
    fi
}

##
# Complete FQN's for classes.
##
__phpns_complete_expand_classes() {
    PHPNS_COMP_OPT='-se' __phpns_complete_FQN
}

##
# Complete (partially) matching classes using phpns's --complete-classes option.
# Recommended for usage where it is possible to cycle through the provided completions
# like readline with menu-complete enabled.
##
__phpns_complete_classes() {
    PHPNS_COMP_OPT='-sc' __phpns_complete_FQN
}

##
# Combine --expand-classes and --complete-classes options to complete FQN's for classes.
##
__phpns_complete_classes_expand_classes() {
    PHPNS_COMP_OPT='-sec' __phpns_complete_FQN
}

##
# Complete FQN's for namespaces.
##
__phpns_complete_namespace_FQN() {
    PHPNS_COMP_OPT='-sn' __phpns_complete_FQN
}

complete -o nospace -o default -F _phpns_complete phpns
