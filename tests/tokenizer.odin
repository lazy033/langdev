package tests

import "core:testing"

import "../lang"

@(test)
hello_world :: proc(t: ^testing.T) {

	tokens := lang.tokenize("./examples/hello_world.toy");
	testing.expect(t, len(tokens) == 5, "Wrong number of tokens")

	testing.expect(t, tokens[0].type == .IDENTIFIER,  "Fail")
	testing.expect(t, tokens[1].type == .OPEN_PAREN,  "Fail")
	testing.expect(t, tokens[2].type == .LIT_STR,  "Fail")
	testing.expect(t, tokens[3].type == .CLOSE_PAREN,  "Fail")
	testing.expect(t, tokens[4].type == .SEMICOLON,  "Fail")
}
