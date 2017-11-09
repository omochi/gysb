//
//  Parser.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

import GysbBase

class Parser {
    struct ParseTextResult {
        var text: TextNode
        var lineEnd: Bool
    }
    
    init(source: String) {
        tokenReader = TokenReader(source: source)
    }
    
    func parse() throws -> Template {
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
                 .leftBrace, .rightBrace, .leftParen, .rightParen,
                 .doubleQuote:
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
                throw Error(message: "invalid codeClose here")
            case .codeLine:
                throw Error(message: "invalid codeLine here")
            case .macroLine:
                throw Error(message: "invalid macroLine here")
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
                     .leftBrace, .rightBrace, .leftParen, .rightParen,
                     .doubleQuote:
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
                        throw Error(message: "no token")
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

        let openToken = tokenReader.read()
        guard openToken == .codeOpen else
        {
            throw Error(message: "no codeOpen")
        }

        while true {
            let token = tokenReader.read()

            switch token {
            case .codeClose:
                eatWhiteAndNewlineTail()
                return CodeNode(code: code)
            case .end:
                throw Error(message: "no codeClose")
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
        
        if token == .codeLine {
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
        
        if token == .macroLine {
            return try parseMacroLine()
        } else {
            return nil
        }
    }

    private func parseCodeLine() throws -> CodeNode {
        var code: String = ""

        code.append(eatWhiteLead())
        let openToken = tokenReader.read()
        guard openToken == .codeLine else {
            throw Error(message: "no codeLine")
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
        let openToken = tokenReader.read()
        guard openToken == .macroLine else {
            throw Error(message: "no macroLine")
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

        let openToken = tokenReader.read()
        guard openToken == .substOpen else {
            throw Error(message: "no substOpen")
        }
        
        var braceDepth: Int = 0
        
        while true {
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
                throw Error(message: "no substClose")
            default:
                code.append(token.description)
            }
        }
    }

    private let tokenReader: TokenReader
}
