package main

import "core:os"
import "core:fmt"

 SRC_CODE :: `
println("Hello, World");
 `

TokenType :: enum {
	NONE,
	IDENTIFIER,
	OPEN_PAREN,
	// QUOTE, <- should we parse the quote instead of str lit
	LIT_STR,
	CLOSE_PAREN,
	SEMICOLON,
	EOF,
}

TokLoc :: struct {
	filepath: string,
	col: int,
	row: int,
}

Token :: struct {
	type: TokenType,
	loc: TokLoc,
	repr: string,
}

make_token :: proc(c: u8, t: TokenType, col, row: int, filename: string, str := "") -> Token {
	return Token {
		type = t,
		loc = {
			filename,
			col,
			row,
		},
		repr = str == "" ? fmt.tprintf("{:c}", c) : str
	}
}

token_identifier :: proc(cursor: ^int, code: []byte) -> string {
	
	start := cursor^

	for is_letter(code[cursor^]) && cursor^ < len(code) {
		cursor^ += 1
	}

	return string(code[start:cursor^])
}

token_lit_str :: proc(cursor: ^int, code: []byte) -> string {

	// pass open quote
	cursor^ += 1
	start := cursor^

	//fixme: check if str lit adds a new line
	for code[cursor^] != '"' && cursor^ < len(code) {
		cursor^ += 1	
	}

	//fixme: dont assert, do a pretty message
	assert(code[cursor^] == '"', "Unclosed string literal!")

	// pass close quote
	defer cursor^ += 1

	return string(code[start:cursor^])	
}

tokenize :: proc(filepath: string) -> []Token {

	if !os.exists(filepath) {
		fmt.panicf("Tokenizer: File provided doesn't exist. File:{}\n", filepath)
	}
 
	code, ok := os.read_entire_file(filepath)
	if !ok {
		fmt.panicf("Tokenizer: Failed to load file: {}.\n", filepath)
	}

	res := [dynamic]Token{}

	cursor := int(0)
	col := 1
	row := 1

	for cursor < len(code) {
		switch code[cursor] {
		case '\t', ' ':
			cursor += 1
			col += 1
		case '\n', '\r':
			cursor += 1
			row += 1
			col = 0
		case '(':
			append(&res, make_token(code[cursor], .OPEN_PAREN, col, row, filepath))
			cursor += 1
			col += 1
		case ')':
			append(&res, make_token(code[cursor], .CLOSE_PAREN, col, row, filepath))
			cursor += 1
			col += 1
		case ';':
			append(&res, make_token(code[cursor], .SEMICOLON, col, row, filepath))
			cursor += 1
			col += 1
		case '"':
			lit_str := token_lit_str(&cursor, code)
			append(&res, make_token(0, .LIT_STR, col, row, filepath, lit_str))
			col += len(lit_str) + 1
		case:
			fmt.println(is_letter(code[cursor]), code[cursor])
			if is_letter(code[cursor]) {
				identifier := token_identifier(&cursor, code)
				append(&res, make_token(0, .IDENTIFIER, col, row, filepath, identifier))
				col += len(identifier)
			} else {
				fmt.panicf("Parsing of {:c} not handled! {}\n", code[cursor], fmt_tokloc({filepath, col, row}))
			}
		}
	}

	return res[:]
}

fmt_tokloc :: proc(tokloc: TokLoc) -> string {
	return fmt.tprintf("{}:{}:{}", tokloc.filepath, tokloc.row, tokloc.col)
}

is_letter :: proc(c: u8) -> bool {
	return (c >= 97 && c <= 122) || (c >= 65 && c <= 90)
}

main :: proc() {
	
	tokens := tokenize("./test.toy")
	fmt.println("Tokens: ")

	for t in tokens {
		fmt.println("   ", t.repr, t.type)
	}
}
