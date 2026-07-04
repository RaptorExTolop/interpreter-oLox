package main

import "core:path/filepath"
import "core:strings"
import "base:runtime"
import "core:fmt"
import "core:os"

main :: proc() {
	// the args
	argv := os.args
	// the length of the args
	argc := len(os.args)

	// create a new allocator for all memory 
	// will be freed as soon as possible
	allocator := context.temp_allocator
	defer free_all(allocator)

	// if the length count is to large exit
	if (argc > 2) {
		fmt.printf("Usage: jLox [script]\n")
		os.exit(64)
	}
	// if there is 2 args, 1 must be file
	if (argc == 2) {
		ext := filepath.ext(argv[1])
		if (ext != ".lox") {
			errMessage := fmt.tprintf(
							"File must be of type .lox, inputed: {}", ext
						)
			print_err(new_error(errMessage), 68)
		}
		run_file(argv[1], allocator)
		
	// otherwise put the user into prompt mode
	} else {
		run_prompt(allocator)
	}
}

run_file :: proc(file_name: string, allocator: runtime.Allocator) {
	fmt.printf("Running file: {}\n", file_name)
	data, err := os.read_entire_file(file_name, allocator)
	if (err != nil) {
		errMessage := fmt.tprintf("Unable to read from file: {}", err)
		print_err(
			new_error(errMessage), 64
		)
	}

	e := run(string(data), allocator)
	if (e != nil) {
		print_err(e, 69)
	}
}

run_prompt :: proc(allocator: runtime.Allocator) {
	fmt.printf("Welcome to the lox prompt! If you would like to exit, type: exit\n")
	for {
		fmt.printf(">>> ")

		buf: [1024]byte
		n, err := os.read(os.stdin, buf[:])

		if (err != nil) {
			fmt.printf("Error reading input: {}", err)
			errMessage := fmt.tprintf("Error reading input: {}\n", err)
			print_err(
				new_error(errMessage), 65
			)
		}

		input := strings.trim_space(string(buf[:n])) 

		if (input == "exit" || input == "") {
			return 
		}

		e := run(input, allocator)
		if (e != nil) {
			print_err(e)
		}
	}

	return 
}

run :: proc(code: string, allocator: runtime.Allocator) -> (error: Error) {
	scanner := new_scanner(code)
	err := scan_tokens(&scanner)

	if (err != nil) {
		return err
	}

	for token in scanner.tokens {
		fmt.printf("{}\n", token_to_string(token))
	}

	return nil
}
