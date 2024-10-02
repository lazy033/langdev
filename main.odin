package main

import "core:fmt"

import "lang"

main :: proc() {
	tokens := lang.tokenize("./examples/hello_world.toy")
	fmt.println("Tokens: ")

	for t in tokens {
		fmt.println("   ", t.repr, t.type)
	}
}
