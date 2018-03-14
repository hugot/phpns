export PATH="$(pwd)/bin:$PATH"
hash phpns

setup() {
    cd ./test/fixtures/composer_project
}

@test "Outputs filename for a class" {
    declare expected='src/Entity/Post.php'
    run phpns filepath --silent App\\Entity\\Post
    
    echo "output = $output"
    [[ "$output" == "$expected" ]]
}
