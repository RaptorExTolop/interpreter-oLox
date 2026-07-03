# Get the absolute path of the current directory, then extract the last part
PROJECT_NAME := $(notdir $(patsubst %/,%,$(CURDIR)))

# Use it to define your output file
OUTPUT := $(PROJECT_NAME)

# 1. Intercept the arguments after the first command
ifeq ($(firstword $(MAKECMDGOALS)),run)

  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # 2. Turn those arguments into "do-nothing" targets so make doesn't complain
  $(eval $(RUN_ARGS):;@:)
endif

.SILENT:

build: clear
	mkdir -p build/
	odin build src/ -out:build/$(OUTPUT) -debug

clear:
	rm -rf build

run: build
	./build/$(OUTPUT) $(RUN_ARGS)

build-release: clear
	mkdir -p build/
	odin build src -out:build/$(OUTPUT) -o:speed
