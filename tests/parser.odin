package tests

import "core:testing"

import "../lang"

@(test)
hello_world_parser :: proc(t: ^testing.T) {
	tokens := lang.tokenize("./examples/hello_world.toy")
	top_level :=  lang.parse(tokens)

	u, ok := top_level.type.(lang.ScopeExpr)
	testing.expect(t, ok, "Expected top_level to be a ScopeExpr")
	
}
