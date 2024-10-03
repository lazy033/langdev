package lang

import "core:fmt"

// :global
tokens : []Token
token_idx := 0

ScopeExpr :: struct {
	exprs: []Expr,
}

FnCallExpr :: struct {
	id: Token,
	args: []Expr,
}

LiteralStrExpr :: struct {
	repr: Token
}

Expr :: struct {
	type: union {
		ScopeExpr,
		FnCallExpr,
		LiteralStrExpr,
	}
}

parse_expr :: proc() -> Expr {
	#partial switch current_token().type {
	case .IDENTIFIER:
		return try_parse_identifier();
	case .LIT_STR:
		return parse_str_literal_expr(); 
	}

	fmt.panicf("Unreachable! {}\n", current_token())
}

parse_str_literal_expr :: proc() -> Expr {

	lit_expr := LiteralStrExpr{}

	assert(expect_token(.LIT_STR), "Expected string literal")
	lit_expr.repr = consume()

	return { type = lit_expr }
}

try_parse_identifier :: proc() -> Expr {
	if next_token_is(.OPEN_PAREN) {
		return parse_fncall()
	}

	fmt.panicf("Unreachable!\n")
}

parse_fncall :: proc() -> Expr {
	fncall_expr := FnCallExpr{} 

	fncall_expr.id = consume()

	assert(expect_token(.OPEN_PAREN, true), "Expected '('")

	args := [dynamic]Expr{}

	for !expect_token(.CLOSE_PAREN) && token_idx < len(tokens) {
		append(&args, parse_expr())
		// fixme: we only care about one argument for now
		// check for commas
	}

	assert(expect_token(.CLOSE_PAREN, true), "Expected ')'")

	fncall_expr.args = args[:]

	return {
		type = fncall_expr
	}
}

parse_scope :: proc() -> Expr {
	scope_expr := ScopeExpr{}
	exprs := [dynamic]Expr{}

	//fixme: check for end of file
	for token_idx < len(tokens) {
		append(&exprs, parse_expr())
		assert(expect_token(.SEMICOLON, true), "Expected semicolon after scope expression")
	}

	scope_expr.exprs = exprs[:]

	return { type = scope_expr }
}

parse :: proc(tokens_: []Token) -> Expr {
	tokens = tokens_
	return parse_scope() 
}

current_token :: proc() -> Token {
	return tokens[token_idx]
}

expect_token :: proc(t: TokenType, consume := false) -> bool {
	defer if consume { token_idx += 1 }
	return current_token().type == t
}

// fixme: check for EOF token
next_token_is :: proc(t: TokenType) -> bool {
	return tokens[token_idx + 1].type == t
}

consume :: proc() -> Token {
	defer token_idx += 1
	return current_token()
}
