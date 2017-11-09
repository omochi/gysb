//
//  Parser.swift
//  GysbMacroLib
//
//  Created by omochimetaru on 2017/11/10.
//

import Foundation
import GysbBase

class Parser {
    init(tokenReader: TokenReader) {
        self.tokenReader = tokenReader
    }
    
    func parse() throws -> [AnyASTNode] {
        eatWhiteAndNewline()
        
        var result = [AnyASTNode]()
        while true {
            guard let exp = try mayParseExpression() else {
                break
            }
            result.append(exp)
            
            eatWhiteAndNewline()
        }
        
        return result
    }
    
    private func parseCall() throws -> CallNode {
        let nameToken = tokenReader.read()
        guard case .keyword(_) = nameToken else {
            throw Error(message: "no keyword")
        }
        eatWhite()
        
        let leftParenToken = tokenReader.read()
        guard case .leftParen = leftParenToken else {
            throw Error(message: "no leftParen")
        }
        eatWhiteAndNewline()
        
        var args: [AnyASTNode] = []
        while true {
            guard let arg = try mayParseExpression() else {
                break
            }
            args.append(arg)
            eatWhiteAndNewline()
            
            var argEnd = false
            let pos = tokenReader.position
            let commaToken = tokenReader.read()
            switch commaToken {
            case .comma:
                eatWhiteAndNewline()
                break
            case .rightParen:
                tokenReader.seekTo(position: pos)
                argEnd = true
            default:
                throw Error(message: "invalid token, expected comma or rightParen: \(commaToken)")
            }
            
            if argEnd {
                break
            }
        }
        
        let rightParenToken = tokenReader.read()
        guard case .rightParen = rightParenToken else {
            throw Error(message: "no rightParen: \(rightParenToken)")
        }
        
        return CallNode(name: nameToken.description, args: args)
    }
    
    private func mayParseExpression() throws -> AnyASTNode? {
        let pos = tokenReader.position
        let token = tokenReader.read()
        switch token {
        case .keyword:
            tokenReader.seekTo(position: pos)
            return AnyASTNode(try parseCall())
        case .stringLiteral(let str):
            return AnyASTNode(StringLiteralNode(string: str))
        default:
            return nil
        }
    }
    
    @discardableResult
    private func eatWhite() -> String {
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
    
    @discardableResult
    private func eatWhiteAndNewline() -> String {
        var ret = ""
        while true {
            let pos = tokenReader.position
            let token = tokenReader.read()
            
            switch token {
            case .white, .newline:
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
