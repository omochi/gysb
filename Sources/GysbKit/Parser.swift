//
//  Parser.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

import Foundation
import GysbBase

public class Parser {
    public struct ParseTextResult {
        var text: TextNode
        var lineEnd: Bool
    }
    
    public init(source: String, path: URL?) {
        self.path = path
        tokenReader = TokenReader(source: source)
    }
    
    public func parse() throws -> Template {
        var children = [AnyASTNode]()
        while let nodes = try parseLine() {
            nodes.forEach { node in
                children.append(node)
            }
        }
        return Template(children: children)
    }
    
    private func parseLine() throws -> [AnyASTNode]? {
        if let codeLine = try mayParseCodeLine() {
            return [AnyASTNode(codeLine)]
        }
        
        if let macroLine = try mayParseMacroLine() {
            return [AnyASTNode(macroLine)]
        }

        var ret = [AnyASTNode]()

        var firstLoop = true

        while true {
            let pos = tokenReader.position
            let token = tokenReader.read()
            
            switch token {
            case .char, .newline, .white,
                 .leftBrace, .rightBrace:
                tokenReader.seekTo(position: pos)
                let textRet = try parseText()
                ret.append(AnyASTNode(textRet.text))
                if textRet.lineEnd {
                    return ret
                }
            case .codeOpen:
                tokenReader.seekTo(position: pos)
                let code = try parseCodeBlock()
                ret.append(AnyASTNode(code))
                return ret
            case .codeClose:
                throw makeError(message: "invalid codeClose here", position: pos)
            case .codeLine:
                throw makeError(message: "invalid codeLine here", position: pos)
            case .macroLine:
                throw makeError(message: "invalid macroLine here", position: pos)
            case .substOpen:
                tokenReader.seekTo(position: pos)
                let subst = try parseSubst()
                ret.append(AnyASTNode(subst))
            case .end:
                if firstLoop {
                    return nil
                } else {
                    return ret
                }
            }
            
            firstLoop = false
        }
    }
    
    private func parseText() throws -> ParseTextResult {
        var text: String = ""
        var lineEnd = false

        func loop() throws {
            var firstLoop = true

            while true {
                let pos = tokenReader.position
                let token = tokenReader.read()

                switch token {
                case .char, .white,
                     .leftBrace, .rightBrace:
                    text.append(token.description)
                case .newline:
                    text.append(token.description)
                    lineEnd = true
                    return
                case .codeOpen, .codeClose, .codeLine, .macroLine, .substOpen:
                    tokenReader.seekTo(position: pos)
                    return
                case .end:
                    if firstLoop {
                        throw makeError(message: "no token", position: pos)
                    } else {
                        return
                    }
                }

                firstLoop = false
            }
        }
        try loop()

        return ParseTextResult(text: TextNode(text: text),
                               lineEnd: lineEnd)
    }
    
    private func parseCodeBlock() throws -> CodeNode {
        var code: String = ""

        let pos = tokenReader.position
        let openToken = tokenReader.read()
        guard case .codeOpen = openToken else {
            throw makeError(message: "no codeOpen", position: pos)
        }

        while true {
            let pos = tokenReader.position
            let token = tokenReader.read()

            switch token {
            case .codeClose:
                eatWhiteAndNewlineTail()
                return CodeNode(code: code)
            case .end:
                throw makeError(message: "no codeClose", position: pos)
            default:
                code.append(token.description)
            }
        }
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

    @discardableResult
    private func eatWhiteAndNewlineTail() -> String {
        var ret = ""
        while true {
            let pos = tokenReader.position
            let token = tokenReader.read()

            switch token {
            case .white:
                ret.append(token.description)
                break
            case .newline, .end:
                ret.append(token.description)
                return ret
            default:
                tokenReader.seekTo(position: pos)
                return ret
            }
        }
    }

    private func mayParseCodeLine() throws -> CodeNode? {
        let pos = tokenReader.position

        eatWhiteLead()

        let token = tokenReader.read()
        tokenReader.seekTo(position: pos)
        
        if case .codeLine = token {
            return try parseCodeLine()
        } else {
            return nil
        }
    }
    
    private func mayParseMacroLine() throws -> MacroNode? {
        let pos = tokenReader.position
        
        eatWhiteLead()
        
        let token = tokenReader.read()
        tokenReader.seekTo(position: pos)
        
        if case .macroLine = token {
            return try parseMacroLine()
        } else {
            return nil
        }
    }

    private func parseCodeLine() throws -> CodeNode {
        var code: String = ""

        code.append(eatWhiteLead())
        
        let pos = tokenReader.position
        let openToken = tokenReader.read()
        guard case .codeLine = openToken else {
            throw makeError(message: "no codeLine", position: pos)
        }

        while true {
            let token = tokenReader.read()

            switch token {
            case .newline, .end:
                code.append(token.description)
                return CodeNode(code: code)
            default:
                code.append(token.description)
            }
        }
    }
    
    private func parseMacroLine() throws -> MacroNode {
        var code: String = ""
        
        code.append(eatWhiteLead())
        
        let pos = tokenReader.position
        let openToken = tokenReader.read()
        guard case .macroLine = openToken else {
            throw makeError(message: "no macroLine", position: pos)
        }
        
        while true {
            let token = tokenReader.read()
            
            switch token {
            case .newline, .end:
                code.append(token.description)
                return MacroNode(code: code)
            default:
                code.append(token.description)
            }
        }
    }
    
    private func parseSubst() throws -> SubstNode {
        var code: String = ""

        let pos = tokenReader.position
        let openToken = tokenReader.read()
        guard case .substOpen = openToken else {
            throw makeError(message: "no substOpen", position: pos)
        }
        
        var braceDepth: Int = 0
        
        while true {
            let pos = tokenReader.position
            let token = tokenReader.read()
            
            switch token {
            case .leftBrace:
                code.append(token.description)
                braceDepth += 1
            case .rightBrace:
                if braceDepth > 0 {
                    code.append(token.description)
                    braceDepth -= 1                    
                } else {
                    return SubstNode(code: code)
                }
            case .end:
                throw makeError(message: "no substClose", position: pos)
            default:
                code.append(token.description)
            }
        }
    }
    
    private func makeError(message: String, position: TokenReader.Position) -> ParserError {
        return ParserError.init(message: message,
                                path: path,
                                line: position.line,
                                column: position.column)
    }

    private let tokenReader: TokenReader
    private let path: URL?
}
