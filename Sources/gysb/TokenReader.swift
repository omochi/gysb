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
    
    func advance() {
        index = source.index(after: index)
    }

    func read() -> Token {
        guard let ch = source.getOrNone(index) else {
            return .end
        }
        advance()
        
        switch ch {
        case Character("\r"):
            switch source.getOrNone(index) {
            case .some(Character("\n")):
                advance()
                return .newline("\r\n")
            default:
                return .newline("\r")
            }
        case Character("\n"):
            return .newline("\n")
        case Character(" "):
            return .white(" ")
        case Character("\t"):
            return .white("\t")
        case Character("%"):
            switch source.getOrNone(index) {
            case .some(Character("%")):
                // escaped
                advance()
                return .char("%")
            case .some(Character("{")):
                advance()
                return .codeOpen
            default:
                return .codeLine
            }
        case Character("$"):
            switch source.getOrNone(index) {
            case .some(Character("$")):
                // escaped
                advance()
                return .char("$")
            case .some(Character("{")):
                advance()
                return .substOpen
            default:
                return .char("$")
            }
        case Character("{"):
            return .leftBrace
        case Character("}"):
            switch source.getOrNone(index) {
            case .some(Character("%")):
                advance()
                return .codeClose
            default:
                return .rightBrace
            }
        default:
            return .char(String(ch))
        }
    }
    
    private var source: String
    private var index: String.Index
}
