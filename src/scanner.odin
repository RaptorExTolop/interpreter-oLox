package main

import "core:strconv"
import "core:c"
import "core:math"
import "core:fmt"

// The scanner struct
// The scanner scans the file and produces tokens
Scanner :: struct {
	// The source code it is reading from
	source: string,
	// The tokens it will produce
	tokens: [dynamic]Token,
	// The start of the current lexeme, where we are currently in the lexeme,
	// and the current line that we are on
	start, current, line: int,
}

// create a new scanner with default values
new_scanner :: proc(source: string) -> Scanner {
	return {
		source = source,
		tokens = {},
		start = 0,
		current = 0,
		line = 1,
	}
}

// scan all of the tokens based on a scanner
// returns and error that must be handled
scan_tokens :: proc(self: ^Scanner) -> (error: Error) {
	// reset the scanner just in case
	self.start = 0
	self.current = 0
	self.line = 1

	// the program has not failed yet 
	hasFailed := false

	// while the scanner is not at the end of the source code
	for (!scanner_is_at_end(self)) {
		// set the start of the lexeme to the current position
		// as we are starting a new lexeme
		self.start = self.current

		// scan for the next token
		err := scan_token(self)
		// if there is an error print it
		// the program has now had an error, 
		// so set the hasFailed flag to be true
		if (err != nil) {
			print_err(err)
			hasFailed = true
		}
	}

	// append a file end of file token onto the end of the tokens
	append(&self.tokens, new_token( .EOF, "", self.line))

	// if the program failed
	if (hasFailed) {
		// RIP program I guess
		errMessage := fmt.tprintf("Program has experienced unexpected errors")
		return new_error(
			errMessage
		)
	}
	// return no errors
	return nil
}

@(private="file")
// return if the scanner is at the end of the source code
scanner_is_at_end :: proc(self: ^Scanner) -> bool {
	// if the current index is greater than the length of the
	// source code
	return self.current >= len(self.source)
}

@(private="file")
// scan for the next token
scan_token :: proc(self: ^Scanner) -> Error {
	// get the next rune
	c: rune = advance(self)
	switch (c) {
	// ONE CHAR CASE
	// simply add the token based on the char
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
	// MULTI CHAR CASE
	// check for the 'match' of the next token expected.
	// if the next token is there, do the double char
	// otherwise just a single char
	case '!':
		add_token(self, match_token(self, '=') ? .BANG_EQUAL : .BANG)
	case '=':
		add_token(self, match_token(self, '=') ? .EQUAL_EQUAL : .EQUAL)
	case '>':
		add_token(self, match_token(self, '=') ? .GREATER_EQUAL : .GREATER)
	case '<':
		add_token(self, match_token(self, '=') ? .LESS_EQUAL : .LESS)
	case '/':
		if (match_token(self, '/')) {
			for (peak(self) != '\n' && !scanner_is_at_end(self)) { advance(self) }
		} else {
			add_token(self, .SLASH)
		}
	case '"':
		for (peak(self) != '"' && !scanner_is_at_end(self)) {
			if (peak(self) != '\n') do self.line += 1
			advance(self)
		}

		if (scanner_is_at_end(self)) {
			return new_error(self.line, "Unterminated string", "String must have a closing \" before EOF")
		}
		advance(self)
		value := transmute([]u8)self.source[self.start+1:self.current-1]
		add_token(self, .STRING, value)
	
	// if there is a new line, we have to increase the number of lines
	case '\n':
		self.line += 1
	// ignore whitespaces and tabs, they are not used in this language
	case ' ', '\t', '\r':
	// if the character is none of the expected characters, the create a new error
	// and return it
	case:
		if (is_char_digit(c)) {
			scan_number(self)
		} else {
			errMessage := fmt.tprintf("character: {} unexpected", c)
			return new_error(self.line, errMessage, "character not defined")
		}
	}

	// return no errors
	return nil
}

is_char_digit :: proc(char: rune) -> bool {
	return char >= '0' && char <='9'
}

@(private="file")
scan_number :: proc(self: ^Scanner) {
	for is_char_digit(peak(self)) do advance(self)

	if peak(self) == '.' && is_char_digit(peak(self, 2)) {
		advance(self)

		for is_char_digit(peak(self)) do advance(self)
	}

	num, err := strconv.parse_int(self.source[self.start:self.current])
	if (err) {
		error := new_error(self.line, "Tried to parse something that is not a number", "Error in lexer")
		print_err(error)
	}
	value := transmute([size_of(num)]byte)num
	add_token(self, .NUMBER, value[:])
}

@(private="file")
peak :: proc(self: ^Scanner, amount: int = 1) -> rune {
	if (scanner_is_at_end(self)) do return rune(0)
	return rune(self.source[self.current + (amount - 1)])
}

@(private="file")
// advance based on amount (1)
advance :: proc(self: ^Scanner, amount: int = 1) -> rune {
	// get the current rune
	rune := rune(self.source[self.current])
	// increase current by 1
	self.current += amount
	// return the rune
	return rune
}

@(private="file")
// add a new token
add_token :: proc(self: ^Scanner, type: TokenType, literal: []byte = {}) {
	// create the lexeme string
	// the lexeme comes from the start of the lexeme
	// got earlier in the scan_tokens() function, to where
	// we currently are in the program lifetime
	text := self.source[self.start:self.current]
	// append a new token to the tokens array
	append(&self.tokens, new_token(type, text, self.line, literal))
}

@(private="file")
// check the next rune against the expected rune
match_token :: proc(self: ^Scanner, expected: rune) -> bool {
	// if the scanner is at the end, return false
	// can give a out of bounds error otherwise
	if (scanner_is_at_end(self)) do return false
	// advance in the char, if it is not the expected character 
	// go back to the previous character and return false
	if (advance(self) != expected) {
		self.current -= 1
		return false
	}
	// otherwise return true
	return true
}

