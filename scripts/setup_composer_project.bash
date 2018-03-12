#!/bin/bash

set -e

#shellcheck disable=SC2012
if [[ -d test/fixtures/composer_project ]]; then
    echo 'Composer project dir already exists, skipping.' >&2
    exit 0
elif ! which composer &>>/dev/null; then
    echo 'You need to have composer installed on your computer to run this script.' >&2
    exit 1
fi

mkdir -p test/fixtures/composer_project

(cd test/fixtures/composer_project \
    && git clone https://github.com/symfony/demo.git . \
    && git checkout v1.2.2 \
    && composer install)
