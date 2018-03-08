_phpns_complete () 
{ 
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
        "${COMP_WORDS[COMP_CWORD]}")
            declare -a commands=(
            'ns'  'namespace'
            'i'   'index'
            'fu'  'find-use '
            'fxu' 'fix-uses'
            'cns' 'classes-in-namespace'
            'cmp' 'complete'
            'help' 
            )
            COMPREPLY=($(compgen -W "${commands[*]}" "${COMP_WORDS[COMP_CWORD]}"))
            ;;
    esac
}

__phpns_complete_complete()
{
    declare word="${COMP_WORDS[COMP_CWORD]}"
    case "$word" in
        '-')
            COMPREPLY=($(compgen -P '-' -W 'i' "${word/-/}"))
            ;;
        --*)
            COMPREPLY=($(compgen -P '--' -W 'be-smart' "${word/--/}"))
            ;;
        *)
            __phpns_complete_use_path
            ;;
    esac
}

__phpns_complete_fix_uses()
{
    declare word="${COMP_WORDS[COMP_CWORD]}"
    case "$word" in 
        '-')
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

__phpns_complete_find_use()
{
    declare word="${COMP_WORDS[COMP_CWORD]}"
    case "$word" in 
        '-')
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

__phpns_complete_use_path() 
{
    declare word="${COMP_WORDS[COMP_CWORD]}";
    if [[ $word == "'"* ]]; then
        word="${word//"'"/}"
        COMPREPLY=($(phpns cmp -i "${word//\\\\/\\}" | while read -r line; do echo "'$line'"; done))
    elif [[ $word == '"' ]]; then
        word="${word//'"'/}"
        COMPREPLY=($(phpns cmp -i "${word//\\\\/\\}" | while read -r line; do echo "\"${line//\\/\\\\}\""; done))
    else
        COMPREPLY=($(phpns cmp -i "${word//\\\\/\\}" | while read -r line; do echo "${line//\\/\\\\}"; done))
    fi
}

complete -o nospace -F _phpns_complete phpns
