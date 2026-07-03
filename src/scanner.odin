package main

import "core:strings"
import "core:fmt"
import "core:bytes"
Scanner :: struct {
	source: string,
	tokens: [dynamic]Token,
	start, current, line: int,
}

new_scanner :: proc(source: string) -> Scanner {
	return {
		source = source,
		tokens = {},
		start = 0,
		current = 0,
		line = 1,
	}
}

scan_tokens :: proc(self: ^Scanner) -> (error: Error) {
	self.start = 0
	self.current = 0
	self.line = 1
	hasFailed := false

	for (!scanner_is_at_end(self)) {
		self.start = self.current
		err := scan_token(self)
		if (err != nil) {
			print_err(err)
			hasFailed = true
		}
	}

	append(&self.tokens, new_token( .EOF, "", self.line))

	if (hasFailed) {
		errMessage := fmt.tprintf("Program has excited due to unexpected errors")
		return new_error(
			errMessage
		)
	}
	return nil
}

@(private="file")
scanner_is_at_end :: proc(self: ^Scanner) -> bool {
	return self.current >= len(self.source)
}

@(private="file")
scan_token :: proc(self: ^Scanner) -> Error {
	c: rune = advance(self)
	switch (c) {
	case '(': add_token(self, .LEFT_PARAN)
	case ')': add_token(self, .RIGHT_PARAN)
	case '{': add_token(self, .LEFT_BRACE)
	case '}': add_token(self, .RIGHT_BRACE)
	case ',': add_token(self, .COMMA)
	case '.': add_token(self, .DOT)
	case '-': add_token(self, .MINUS)
	case '+': add_token(self, .PLUS)
	case ';': add_token(self, .SEMICOLON)
	case '*': add_token(self, .STAR)
	
	case ' ', '\t', '\n':
	case:
		errMessage := fmt.tprintf("character: {} unexpected", c)
		return new_error(self.line, errMessage, "character not defined")
	}

	return nil
}

@(private="file")
advance :: proc(self: ^Scanner, amount: int = 1) -> rune {
	rune := rune(self.source[self.current])
	self.current += amount
	return rune
}

@(private="file")
add_token :: proc(self: ^Scanner, type: TokenType, literal: []byte = {}) {
	text := self.source[self.start:self.current]
	append(&self.tokens, new_token(type, text, self.line, literal))
}

