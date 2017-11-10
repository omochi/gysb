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
        
        var line: Int
        var column: Int
    }
    
    init(source: String) {
        self.source = source
        
        self._position = Position(index: source.startIndex,
                                  line: 1,
                                  column: 1)
    }
    
    var position: Position {
        return _position
    }
    
    func seekTo(position: Position) {
        _position = position
    }
    
    func read() -> Token {
        guard let ch = readChar() else {
            return .end
        }
        
        func emitNewLine(_ s: String) -> Token {
            self._position = Position(index: _position.index,
                                      line: _position.line + 1,
                                      column: 1)
            return .newline(s)
        }
        
        switch ch {
        case "\r":
            let pos = position
            switch readChar() {
            case .some("\n"):
                return emitNewLine("\r\n")
            default:
                seekTo(position: pos)
                return emitNewLine("\r")
            }
        case "\n":
            return emitNewLine("\n")
        case " ":
            return .white(" ")
        case "\t":
            return .white("\t")
        case "%":
            let pos = position
            switch readChar() {
            case .some("%"):
                // escaped
                return .char("%")
            case .some("{"):
                return .codeOpen
            case .some("!"):
                return .macroLine
            default:
                seekTo(position: pos)
                return .codeLine
            }
        case "$":
            let pos = position
            switch readChar() {
            case .some("$"):
                // escaped
                return .char("$")
            case .some("{"):
                return .substOpen
            default:
                seekTo(position: pos)
                return .char("$")
            }
        case "{":
            return .leftBrace
        case "}":
            let pos = position
            switch readChar() {
            case .some("%"):
                return .codeClose
            default:
                seekTo(position: pos)
                return .rightBrace
            }
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
        if position.index == source.endIndex {
            return nil
        }
        let char = String(source[position.index])
        self._position = Position(index: source.index(after: position.index),
                                  line: position.line,
                                  column: position.column + 1)
        return char
    }
    
    private var source: String
    private var _position: Position
}
