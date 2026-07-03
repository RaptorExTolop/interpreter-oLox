package main

import "core:fmt"
import "core:os"

Error :: union {
	InterpreterError,
	GenError,
}

InterpreterError  :: struct {
	line: u32,
	location: string,
	message: string,
}

GenError :: struct {
	message: string
}

new_error :: proc {
	new_gen_err,
	new_interpreter_error,
}

@(private="file")
new_interpreter_error :: proc(line: u32, location, message: string) -> InterpreterError {
	return {
		line = line,
		location = location,
		message = message,
	}
}


@(private="file")
new_gen_err :: proc(message: string) -> GenError {
	return {
		message = message
	}
}

print_err :: proc {
	print_err_fatal,
	print_err_non_fatal
}

@(private="file")
print_err_non_fatal :: proc(err: Error) {
	switch &e in err {
	case (GenError):
		print_gen_error_non_fatal(&e)
	case (InterpreterError):
		print_int_error_non_fatal(&e)
	}
}

@(private="file")
print_err_fatal :: proc(err: Error, code: int) {
	switch &e in err {
	case (GenError):
		print_gen_error_fatal(&e, code)
	case (InterpreterError):
		print_int_error_fatal(&e, code)
	}
}

@(private="file")
print_int_error_non_fatal :: proc(self: ^InterpreterError) {
	fmt.printf("[line {}] Error {}: {}\n", self.line, self.location, self.message)
}

@(private="file")
print_int_error_fatal :: proc(self: ^InterpreterError, code: int) {
	print_int_error_non_fatal(self)
	os.exit(code)
}

@(private="file")
print_gen_error_non_fatal :: proc(self: ^GenError) {
	fmt.printf("{}\n", self.message)
}

@(private="file")
print_gen_error_fatal :: proc(self: ^GenError, code: int) {
	print_gen_error_non_fatal(self)
	os.exit(code)
}

