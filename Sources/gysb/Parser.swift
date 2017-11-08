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
    
    func run(source: String) throws -> Template {
        self.source = source
        self._index = source.startIndex
        
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
            let index = self.index
            let token = readToken()
            
            switch token {
            case .char, .newline, .white, .leftBrace, .rightBrace:
                seekIndex(index)
                let textRet = try parseText()
                ret.append(AnyASTNode(textRet.text))
                if textRet.lineEnd {
                    return ret
                }
            case .codeOpen:
                seekIndex(index)
                let code = try parseCodeBlock()
                ret.append(AnyASTNode(code))
                return ret
            case .codeClose:
                throw Error(message: "invalid codeClose here")
            case .codeLine:
                throw Error(message: "invalid codeLine here")
            case .substOpen:
                seekIndex(index)
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
                let index = self.index
                let token = readToken()

                switch token {
                case .char, .leftBrace, .rightBrace, .white:
                    text.append(token.description)
                case .newline:
                    text.append(token.description)
                    lineEnd = true
                    return
                case .codeOpen, .codeClose, .codeLine, .substOpen:
                    seekIndex(index)
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

        let openToken = readToken()
        guard openToken == .codeOpen else
        {
            throw Error(message: "no codeOpen")
        }

        while true {
            let token = readToken()

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
            let index = self.index
            let token = readToken()

            switch token {
            case .white:
                ret.append(token.description)
                break
            case .newline, .end:
                ret.append(token.description)
                return ret
            default:
                seekIndex(index)
                return ret
            }
        }
    }

    @discardableResult
    private func eatWhiteAndNewlineTail() -> String {
        var ret = ""
        while true {
            let index = self.index
            let token = readToken()

            switch token {
            case .white:
                ret.append(token.description)
                break
            case .newline, .end:
                ret.append(token.description)
                return ret
            default:
                seekIndex(index)
                return ret
            }
        }
    }

    private func mayParseCodeLine() throws -> CodeNode? {
        let index = self.index

        eatWhiteLead()

        let token = readToken()
        if token == .codeLine {
            seekIndex(index)
            return try parseCodeLine()
        } else {
            seekIndex(index)
            return nil
        }
    }

    // TODO: eat leading white
    private func parseCodeLine() throws -> CodeNode {
        var code: String = ""

        code.append(eatWhiteLead())
        let openToken = readToken()
        guard openToken == .codeLine else {
            throw Error(message: "no codeLine")
        }

        while true {
            let token = readToken()

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

        let openToken = readToken()
        guard openToken == .substOpen else {
            throw Error(message: "no substOpen")
        }
        
        var braceDepth: Int = 0
        
        while true {
            let token = readToken()
            
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


    private func readToken() -> Token {
        guard let ch = source.getOrNone(index) else {
            return .end
        }
        advanceIndex()

        switch ch {
        case Character("\r"):
            switch source.getOrNone(index) {
            case .some(Character("\n")):
                advanceIndex()
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
                advanceIndex()
                return .char("%")
            case .some(Character("{")):
                advanceIndex()
                return .codeOpen
            default:
                return .codeLine
            }
        case Character("$"):
            switch source.getOrNone(index) {
            case .some(Character("$")):
                // escaped
                advanceIndex()
                return .char("$")
            case .some(Character("{")):
                advanceIndex()
                return .substOpen
            default:
                return .char("$")
            }
        case Character("{"):
            return .leftBrace
        case Character("}"):
            switch source.getOrNone(index) {
            case .some(Character("%")):
                advanceIndex()
                return .codeClose
            default:
                return .rightBrace
            }
        default:
            return .char(String(ch))
        }
    }

    private func seekIndex(_ index: String.Index) {
        self._index = index
    }

    private func advanceIndex() {
        self._index = source.index(after: index)
    }
    
    private var source: String!
    private var index: String.Index {
        return _index!
    }
    private var _index: String.Index?
}
