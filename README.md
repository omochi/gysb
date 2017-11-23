[![Build Status](https://travis-ci.org/omochi/gysb.svg?branch=master)](https://travis-ci.org/omochi/gysb)

# gysb

gysb is Generate Your Swifty Boilerplate.

Swift implementation of [swift/gyb](https://github.com/apple/swift/blob/master/utils/gyb.py)

# example

```
$ cat TestResources/simple1/a.txt.gysb 
Hello 100%%
%{
    let y = 10
    let x = 42
    func succ(_ a: Int) -> Int {
        return a + 1
    }
}%

I can assure you that ${x} < ${succ(x)}

% if y > 7 {
%    for _ in 0..<3 {
y is greater than seven!
%    }
% } else {
y is less than or equal to seven
% }

The End.
$ swift run gysb Examples/simple1/a.txt.gysb 
Hello 100%

I can assure you that 42 < 43

y is greater than seven!
y is greater than seven!
y is greater than seven!

The End.
```

## other examples

See `Examples` and `Tests`.

# docs

[紹介記事](https://qiita.com/omochimetaru/items/422ddd04e95c55dd3833)

# command line help

```
$ swift run gysb --help
Usage: .build/x86_64-apple-macosx10.10/debug/gysb [mode] [flags] paths...

# mode
    --help: print help
    --parse: print AST
    --compile: print compiled Swift
    --render: render template (default)

# flags
    --write: write output on same directory (extension removed)
    --source-dirs: paths means directory and search *.gysb (automatically enable `--write`)

```

# syntax

- `%%`: escaped `%`
- `$$`: escaped `$`
- `%{ <swift-code> }%`: code block
- `% <swift-code> <newline>`: code line
- `${ <swift-code> }`: code substitution

# gysb.json

You can use more useful feature of gysb by using `gysb.json`.
gysb command search `gysb.json` for each gysb template files within same or ancestor directory.

## gysb.json features

- local library script inclusion. See example in `Examples/simple_include`.
- external library via SwiftPM package. See example in `Examples/yaml`.

# install

There are some install approachs.

1. install from homebrew
2. build yourself and set path

## homebrew

```
$ brew install omochi/taps/gysb
```

## build yourself

Checkout repository.

```
$ git clone https://github.com/omochi/gysb.git
$ cd gysb
```

Build.

```
$ swift build
```

Get path.

```
$ echo $(pwd)/.build/debug
/Users/omochi/github/omochi/gysb/.build/debug
```

Set path.

```
$ vim ~/.bash_profile
```

# development

This repository is maintained by SwiftPM.

Use xcodeproj and work with it.

```
$ swift package generate-xcodeproj
$ open gysb.xcodeproj
```

