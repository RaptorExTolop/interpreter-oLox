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
scanCode :: proc(self: ^Scanner, code: string) -> []Token {
	return {}
}

@(private="file")
scanFromScanner :: proc(self: ^Scanner) -> []Token {
	return {}
}
