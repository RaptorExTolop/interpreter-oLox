package main
bytes :: byte
import "core:fmt"

// All the types of the tokens
TokenType :: enum {
	// single char tokens
	LEFT_PARAN, RIGHT_PARAN, LEFT_BRACE, RIGHT_BRACE,
	COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR,

	// One or two char tokens
	BANG, BANG_EQUAL,
	EQUAL, EQUAL_EQUAL,
	GREATER, GREATER_EQUAL,
	LESS, LESS_EQUAL,

	// Indentifiers
	IDENTIFIER, STRING, NUMBER,

	// Keywords
	AND, CLASS, ELSE, FALSE, FUNC, FOR, IF, NIL, 
	OR, PRINT, RETURN, SUPER, THIS, TRUE, VAR, WHILE,

	EOF
}

Token :: struct {
	type: TokenType,
	// the lexeme is the name of the
	// token. E.g. var for VAR, or x for IDENTIFIER
	lexeme: string,
	// any data that comes with the token
	literal: []bytes,
	// what line the token is on
	line: int,
}

// return a new token
new_token :: proc(type: TokenType, lexeme: string, line: int, literal: []bytes = {}) -> Token {
	return {
		type, lexeme, literal, line
	}
}

// parse the token to a string
token_to_string :: proc(self: Token) -> string {
	return fmt.tprintf("Type: {}, lexeme: {}, data: {}, found on: {}", self.type, self.lexeme, string(self.literal), self.line)
}

