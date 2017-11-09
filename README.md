# gysb

gysb is Generate Your Swifty Boilerplate.

Swift implementation of [swift/gyb](https://github.com/apple/swift/blob/master/utils/gyb.py)

# example

```
$ cat Examples/a.txt.gysb 
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
$ swift run gysb Resources/a.txt.gysb 
Hello 100%

I can assure you that 42 < 43

y is greater than seven!
y is greater than seven!
y is greater than seven!

The End.
```

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
- `%!`: template macro invocation

## macro

- include_code(path): include code here. path: glob pattern.

### example

```
[omochi@omochi-iMac gysb (master +=)]$ ls Examples/libs
func_aaa.swift func_bbb.swift
[omochi@omochi-iMac gysb (master *+=)]$ cat Examples/libs/func_aaa.swift 
func aaa() -> Int {
    return 999
}
[omochi@omochi-iMac gysb (master *+=)]$ cat Examples/libs/func_bbb.swift 
func bbb() -> Int {
    return 777
}
[omochi@omochi-iMac gysb (master *+=)]$ cat Examples/include.swift.gysb 
%! include_code("libs/*.swift")
%
aaa=${aaa()}
bbb=${bbb()}
[omochi@omochi-iMac gysb (master *+=)]$ swift run gysb Examples/include.swift.gysb 
aaa=999
bbb=777
```




