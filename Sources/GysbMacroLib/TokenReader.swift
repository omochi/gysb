import Foundation

class TokenReader {
    struct Position {
        var index: String.Index
    }
    
    init(source: String) {
        self.source = source
        self.index = source.startIndex
    }
    
    var position: Position {
        return Position(index: index)
    }
    
    func seekTo(position: Position) {
        self.index = position.index
    }
    
    func read() -> Token {
        let index = self.index
        guard let ch = readChar() else {
            return .end
        }
        
        if isKeywordHead(ch) {
            self.index = index
            return readKeyword()
        }
        
        switch ch {
        case "\r":
            let index = self.index
            switch readChar() {
            case .some("\n"):
                return .newline("\r\n")
            default:
                self.index = index
                return .newline("\r")
            }
        case "\n":
            return .newline("\n")
        case " ":
            return .white(" ")
        case "\t":
            return .white("\t")
        case "(":
            return .leftParen
        case ")":
            return .rightParen
        case "\"":
            self.index = index
            return readStringLiteral()
        case ",":
            return .comma
        default:
            return .char(ch)
        }
    }
    
    func peek() -> Token {
        let pos = self.position
        let ret = read()
        seekTo(position: pos)
        return ret
    }
    
    private func readKeyword() -> Token {
        var keyword = ""
        let ch = readChar()!
        precondition(isKeywordHead(ch))
        keyword.append(ch)
        while true {
            let index = self.index
            switch readChar() {
            case .some(let ch) where isKeywordBody(ch):
                keyword.append(ch)
            default:
                self.index = index
                return .keyword(keyword)
            }
        }
    }
    
    private func readStringLiteral() -> Token {
        var string = ""
        let ch = readChar()!
        precondition(ch == "\"")
        while true {
            guard let ch = readChar() else {
                return .stringLiteral(string)
            }
            
            switch ch {
            case "\"":
                return .stringLiteral(string)
            default:
                string.append(ch)
                break
            }
        }
    }
    
    private func readChar() -> String? {
        let index = self.index
        if index == source.endIndex {
            return nil
        }
        let char = String(source[index])
        self.index = source.index(after: index)
        return char
    }
    
    private func isKeywordHead(_ s: String) -> Bool {
        return isAlphabet(s) || s == "_"
    }
    
    private func isKeywordBody(_ s: String) -> Bool {
        return isAlphabet(s) || isNumber(s) || s == "_"
    }
    
    private func isAlphabet(_ s: String) -> Bool {
        return ("a"..."z").contains(s) ||
            ("A"..."Z").contains(s)
    }
    
    private func isNumber(_ s: String) -> Bool {
        return ("0"..."9").contains(s)
    }
    
    private var source: String
    private var index: String.Index
}
