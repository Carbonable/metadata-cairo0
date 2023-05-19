.PHONY: build test format

build:
	protostar build-cairo0

install:
	protostar install

test:
	protostar test-cairo0 tests