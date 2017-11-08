//
//  Parser.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

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

        var ret = [AnyASTNode]()

        var firstLoop = true

        while true {
            let pos = tokenReader.position
            let token = tokenReader.read()
            
            switch token {
            case .char, .newline, .white, .leftBrace, .rightBrace:
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
                case .char, .leftBrace, .rightBrace, .white:
                    text.append(token.description)
                case .newline:
                    text.append(token.description)
                    lineEnd = true
                    return
                case .codeOpen, .codeClose, .codeLine, .substOpen:
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
            case .char, .newline, .white,
                 .codeOpen, .codeLine,
                 .substOpen, .leftBrace, .rightBrace:
                code.append(token.description)
            case .codeClose:
                eatWhiteAndNewlineTail()
                return CodeNode(code: code)
            case .end:
                throw Error(message: "")
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
        if token == .codeLine {
            tokenReader.seekTo(position: pos)
            return try parseCodeLine()
        } else {
            tokenReader.seekTo(position: pos)
            return nil
        }
    }

    // TODO: eat leading white
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
            case .char, .white,
                 .codeOpen, .codeClose, .codeLine,
                 .substOpen, .leftBrace, .rightBrace:
                code.append(token.description)
            case .newline, .end:
                code.append(token.description)
                return CodeNode(code: code)
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
            case .char, .newline, .white, .codeOpen, .codeClose, .codeLine,
                 .substOpen:
                code.append(token.description)
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
            }
        }
    }

    private let tokenReader: TokenReader
}
