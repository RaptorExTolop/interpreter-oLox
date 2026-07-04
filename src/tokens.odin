package main
import "core:encoding/endian"
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

TokenValue :: union {
	f64,
	string
}

Token :: struct {
	type: TokenType,
	// the lexeme is the name of the
	// token. E.g. var for VAR, or x for IDENTIFIER
	lexeme: string,
	// any data that comes with the token
	literal: TokenValue,
	// what line the token is on
	line: int,
}

// return a new token
new_token :: proc(type: TokenType, lexeme: string, line: int, literal: TokenValue = nil) -> Token {
	return {
		type, lexeme, literal, line
	}
}

// parse the token to a string
token_to_string :: proc(self: Token) -> string {
	if (self.type != .NUMBER) do return fmt.tprintf("Type: {}, lexeme: {}, data: {}, found on: {}", self.type, self.lexeme, self.literal, self.line)
	return fmt.tprintf("Type: {}, lexeme: {}, data to the 5th degree: %.3f, found on: {}", self.type, self.lexeme, self.literal, self.line)
}

