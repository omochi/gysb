//
//  MacroParser.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

class MacroParser {
    init(tokenReader: TokenReader) {
        self.tokenReader = tokenReader
    }
    
    func parse() throws -> MacroCallNode {
        eatWhiteLead()
        
        let openToken = tokenReader.read()
        guard openToken == .macroLine else {
            throw Error(message: "no macroLine")
        }
        eatWhiteLead()
        
        return try parseMacroCall()
    }
    
    func parseMacroCall() throws -> MacroCallNode {
        let name = try parseKeyword()
        eatWhiteLead()
        
        let leftParenToken = tokenReader.read()
        guard leftParenToken == .leftParen else {
            throw Error(message: "no leftParen")
        }
        eatWhiteLead()
        
        var args: [AnyASTNode] = []
        while let arg = try mayParseExpression() {
            args.append(arg)
            eatWhiteLead()
            
            break
        }

        let rightParenToken = tokenReader.read()
        guard rightParenToken == .rightParen else {
            throw Error(message: "no rightParen")
        }
        eatWhiteLead()
        
        let endToken = tokenReader.read()
        switch endToken {
        case .newline, .end:
            break
        default:
            throw Error(message: "invalid token here: \(endToken)")
        }
        
        return MacroCallNode(name: name, args: args)
    }
    
    private func mayParseExpression() throws -> AnyASTNode? {
        let pos = tokenReader.position

        if let _ = try mayParseKeyword() {
            tokenReader.seekTo(position: pos)
            return AnyASTNode(try parseMacroCall())
        }
        
        if let stringLiteral = try mayParseStringLiteral() {
            return AnyASTNode(stringLiteral)
        }
        
        return nil
    }
    
    private func mayParseStringLiteral() throws -> MacroStringLiteralNode? {
        let token = tokenReader.peek()
        if token == .doubleQuote {
            return try parseStringLiteral()
        } else {
            return nil
        }
    }
    
    private func parseStringLiteral() throws -> MacroStringLiteralNode {
        let token = tokenReader.read()
        guard token == .doubleQuote else {
            throw Error(message: "no doubleQuote")
        }
        
        var str = ""
        while true {
            let token = tokenReader.read()
            
            switch token {
            case .newline, .end:
                throw Error(message: "no close doubleQuote")
            case .doubleQuote:
                return MacroStringLiteralNode(string: str)
            default:
                str.append(token.description)
            }
        }
    }
    
    private func mayParseKeyword() throws -> String? {
        let token = tokenReader.peek()
        if case let .char(ch) = token, isKeywordHead(ch) {
            return try parseKeyword()
        } else {
            return nil
        }
    }
    
    private func parseKeyword() throws -> String {
        var keyword: String = ""
        
        let token = tokenReader.read()
        
        guard case let .char(ch) = token, isKeywordHead(ch) else {
            throw Error(message: "invalid keyword char: [\(token)]")
        }
        keyword.append(token.description)
        
        while true {
            let pos = tokenReader.position
            let token = tokenReader.read()
            
            switch token {
            case let .char(ch) where isKeywordBody(ch):
                keyword.append(token.description)
            default:
                tokenReader.seekTo(position: pos)
                return keyword
            }
        }
    }
    
    private func isAlphabet(_ s: String) -> Bool {
        return ("a"..."z").contains(s) ||
        ("A"..."Z").contains(s)
    }
    
    private func isNumber(_ s: String) -> Bool {
        return ("0"..."9").contains(s)
    }
    
    private func isKeywordHead(_ s: String) -> Bool {
        return isAlphabet(s) || s == "_"
    }
    
    private func isKeywordBody(_ s: String) -> Bool {
        return isAlphabet(s) || isNumber(s) || s == "_"
    }
    
    @discardableResult
    private func eatWhiteLead() -> String {
        var ret = ""
        while true {
            let pos = tokenReader.position
            let token = tokenReader.read()
            
            switch token {
            case .white:
                ret.append(token.description)
                break
            default:
                tokenReader.seekTo(position: pos)
                return ret
            }
        }
    }
    
    private let tokenReader: TokenReader
}
