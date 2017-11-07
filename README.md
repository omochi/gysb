# gysb

gysb is Generate Your Swifty Boilerplate.

Swift implementation of [swift/gyb](https://github.com/apple/swift/blob/master/utils/gyb.py)

# example

```
$ cat Resources/a.txt.gysb 
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


