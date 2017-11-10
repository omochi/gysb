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
$ swift run gysb TestResources/simple1/a.txt.gysb 
Hello 100%

I can assure you that 42 < 43

y is greater than seven!
y is greater than seven!
y is greater than seven!

The End.
```

## other examples

See `Test` and `TestResources`.

# docs

[紹介記事](https://qiita.com/omochimetaru/items/422ddd04e95c55dd3833)

# command line help

```
$ swift run gysb --help
Usage: .build/x86_64-apple-macosx10.10/debug/gysb [mode] path

# mode
    --help: print help
    --parse: print AST
    --macro: print macro evaluated AST
    --compile: print compiled Swift
    --render: render template
```

# syntax

- `%%`: escaped `%`
- `$$`: escaped `$`
- `%{` code `%}`: code block
- `% code`: code line
- `${` code `}`: code substitution

# gysb.json

You can use more useful feature of gysb by using `gysb.json`.
gysb command search `gysb.json` for each gysb template files within same or ancestor directory.

## gysb.json features

- local library script inclusion. See example in `TestExample/simple_include`.
- external library via SwiftPM package. See example in `TestExample/yaml`.

