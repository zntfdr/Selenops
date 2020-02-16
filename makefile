install:
	swift build -c release
	install .build/release/selenops-cli /usr/local/bin/selenops