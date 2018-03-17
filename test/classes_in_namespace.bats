export PATH="$(pwd)/bin:$PATH"
hash phpns

setup() {
    cd ./test/fixtures/composer_project
}

@test "Outputs classes in namespace" {
    declare expected='Tag
User
Comment
Post'
    run phpns cns --silent App\\Entity

    printf 'output: "%s"\n' "$output" >&2
    [[ "$expected" == "$output" ]]
}
