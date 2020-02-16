install:
	swift build -c release
	install .build/release/selenops /usr/local/bin/selenops