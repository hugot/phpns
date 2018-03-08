#!/bin/bash
##
# Messaging functions

debug() {
    if [[ $DEBUG -ge 1 ]]; then
        echo "[DEBUG] => $1" >&2
    fi
}

# shellcheck disable=SC2059
debugf() {
    if [[ $DEBUG -ge 1 ]]; then
        declare format_string="$1"
        shift
        printf "[DEBUG] => $format_string" "$@" >&2
    fi
}

info() {
    if [[ $INFO -eq 1 ]]; then
        echo "[INFO] => $1" >&2
    fi
}

# shellcheck disable=SC2059
infof() {
    if [[ $INFO -eq 1 ]]; then
        declare format_string="$1"
        shift
        printf "[INFO] => $format_string" "$@" >&2
    fi
}
