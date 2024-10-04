package main

import "core:fmt"

import "lang"

main :: proc() {
	tokens := lang.tokenize("./examples/hello_world.toy")
	top_level := lang.parse(tokens)

	// fixme: handle error
	scope, ok := top_level.type.(lang.ScopeExpr)

	lang.c_code_gen(scope)

	fmt.println("Tokens: ")

	for t in tokens {
		fmt.println("   ", t.repr, t.type)
	}

	fmt.println(top_level)
}
