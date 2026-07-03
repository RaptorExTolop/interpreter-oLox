package main

import "core:fmt"
import "core:os"

// create an error union between the two errors in the program
// allows for either error to be returned.
// can also be nil if there is no error.
Error :: union {
	InterpreterError,
	GenError,
}

// an error found in the interpreter
InterpreterError  :: struct {
	// the line the error happend at
	line: int,
	// the location/info about the error
	location: string,
	// what do you want to say to the user about
	// the error -> extra info
	message: string,
}

// just a default error
GenError :: struct {
	message: string
}

// function overload to create the different errors
new_error :: proc {
	new_gen_err,
	new_interpreter_error,
}

@(private="file")
// create a new InterpreterError
new_interpreter_error :: proc(line: int, location, message: string) -> InterpreterError {
	return {
		line = line,
		location = location,
		message = message,
	}
}


@(private="file")
// create a new default gen error
new_gen_err :: proc(message: string) -> GenError {
	return {
		message = message
	}
}

// print either a fatal or non-fatal error
print_err :: proc {
	print_err_fatal,
	print_err_non_fatal
}

@(private="file")
print_err_non_fatal :: proc(err: Error) {
	// go for each type the error could be
	switch &e in err {
	// if it is a general error, print that info
	case (GenError):
		print_gen_error_non_fatal(&e)
	// otherwise if it is a interpreter error, print that info
	case (InterpreterError):
		print_int_error_non_fatal(&e)
	}
}

@(private="file")
print_err_fatal :: proc(err: Error, code: int) {
	switch &e in err {
	// if it is a general error, print that info
	case (GenError):
		print_gen_error_fatal(&e, code)
	// otherwise if it is a interpreter error, print that info
	case (InterpreterError):
		print_int_error_fatal(&e, code)
	}
}

@(private="file")
print_int_error_non_fatal :: proc(self: ^InterpreterError) {
	fmt.printf("Error at line {}: {}, {}\n", self.line, self.location, self.message)
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

