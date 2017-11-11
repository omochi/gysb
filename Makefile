PREFIX?=/usr/local

build:
	swift build

clean:
	swift package clean

xcode:
	swift pakcage generate-xcodeproj

archive:
	swift build --disable-sandbox -Xswiftc -static-stdlib

install: archive
	mkdir -p "$(PREFIX)/bin"
	ln -sf "$(CURDIR)/.build/debug/gysb" "$(PREFIX)/bin/gysb"

