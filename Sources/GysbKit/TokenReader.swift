//
//  TokenReader.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

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
        guard let ch = readChar() else {
            return .end
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
        case "%":
            let index = self.index
            switch readChar() {
            case .some("%"):
                // escaped
                return .char("%")
            case .some("{"):
                return .codeOpen
            case .some("!"):
                return .macroLine
            default:
                self.index = index
                return .codeLine
            }
        case "$":
            let index = self.index
            switch readChar() {
            case .some("$"):
                // escaped
                return .char("$")
            case .some("{"):
                return .substOpen
            default:
                self.index = index
                return .char("$")
            }
        case "{":
            return .leftBrace
        case "}":
            let index = self.index
            switch readChar() {
            case .some("%"):
                return .codeClose
            default:
                self.index = index
                return .rightBrace
            }
        case "(":
            return .leftParen
        case ")":
            return .rightParen
        case "\"":
            return .doubleQuote
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
    
    private func readChar() -> String? {
        let index = self.index
        if index == source.endIndex {
            return nil
        }
        let char = String(source[index])
        self.index = source.index(after: index)
        return char
    }
    
    private var source: String
    private var index: String.Index
}
