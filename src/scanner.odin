package main

Scanner :: struct {
	code: string
}

new_scanner :: proc(code: string) -> Scanner {
	return {
		code = code
	}
}

scan :: proc {
	scanCode,
	scanFromScanner,
}

@(private="file")
scanCode :: proc(self: ^Scanner, code: string) -> (tokens: []Token, err: Error) {
	return {}, {}
}

@(private="file")
scanFromScanner :: proc(self: ^Scanner) -> (tokens: []Token, error: Error) {
	tokens, error = scanCode(self, self.code)
	return tokens, error
}
