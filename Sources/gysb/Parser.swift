//
//  Parser.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

class Parser {
    func run(source: String) throws -> Template {
        self.source = source
        self.index = source.startIndex
        
        var children = [AnyASTNode]()
        while let node = try parseNode() {
            children.append(node)
        }
        return Template(children: children)
    }
    
    private func parseNode() throws -> AnyASTNode? {
        let index = self.index
        guard let token = readToken() else {
            return nil
        }
        self.index = index
        
        switch token {
        case .char, .newline, .leftBrace, .rightBrace:
            return AnyASTNode(try parseText())
        case .codeOpen:
            return AnyASTNode(try parseCodeBlock())
        case .codeClose:
            throw Error(message: "invalid codeClose here")
        case .codeLine:
            return AnyASTNode(try parseCodeLine())
        case .substOpen:
            return AnyASTNode(try parseSubst())
        }
    }
    
    private func parseText() throws -> TextNode {
        var text: String = ""
        
        var index = self.index
        guard var token = readToken() else {
            throw Error(message: "no token")
        }
        
        func loop() {
            while true {
                switch token {
                case .char, .leftBrace, .rightBrace:
                    text.append(token.description)
                case .newline:
                    text.append(token.description)
                    return
                case .codeOpen, .codeClose, .codeLine, .substOpen:
                    self.index = index
                    return
                }
                
                index = self.index
                guard let tk = readToken() else {
                    return
                }
                token = tk
            }
        }
        
        loop()
        
        return TextNode(text: text)
    }
    
    private func parseCodeBlock() throws -> CodeNode {
        var code: String = ""
        
        guard let openToken = readToken(),
            openToken == .codeOpen else
        {
            throw Error(message: "no codeOpen")
        }
        
        while true {
            guard let token = readToken() else {
                throw Error(message: "no codeClose")
            }
            
            switch token {
            case .char, .newline, .codeOpen, .codeLine,
                 .substOpen, .leftBrace, .rightBrace:
                code.append(token.description)
            case .codeClose:
                eatWhiteTail()
                return CodeNode(code: code)
            }
        }
    }
    
    private func eatWhiteTail() {
        while true {
            let index = self.index
            guard let token = readToken() else {
                return
            }
            
            switch token {
            case let .char(char) where isWhiteString(char):
                break
            case .char:
                self.index = index
                return
            case .newline:
                return
            case .codeOpen, .codeClose, .codeLine,
                 .substOpen, .leftBrace, .rightBrace:
                self.index = index
                return                
            }
        }
    }
    
    private func parseCodeLine() throws -> CodeNode {
        var code: String = ""
        
        guard let openToken = readToken(),
            openToken == .codeLine else
        {
            throw Error(message: "no codeLine")
        }
        
        while true {
            guard let token = readToken() else {
                return CodeNode(code: code)
            }
            
            switch token {
            case .char, .codeOpen, .codeClose, .codeLine,
                 .substOpen, .leftBrace, .rightBrace:
                code.append(token.description)
            case .newline:
                code.append(token.description)
                return CodeNode(code: code)
            }
        }
    }
    
    private func parseSubst() throws -> SubstNode {
        var code: String = ""
        
        guard let openToken = readToken(),
            openToken == .substOpen else
        {
            throw Error(message: "no substOpen")
        }
        
        var braceDepth: Int = 0
        
        while true {
            guard let token = readToken() else {
                throw Error(message: "no substClose")
            }
            
            switch token {
            case .char, .newline, .codeOpen, .codeClose, .codeLine,
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
            }
        }
    }
    
    private func isWhiteString(_ string: String) -> Bool {
        return string.testAll { isWhiteCharacter($0) }
    }
    
    private func isWhiteCharacter(_ char: Character) -> Bool {
        switch String(char) {
        case " ", "\r", "\n", "\t":
            return true
        default:
            return false
        }
    }
    
    private func readToken() -> Token? {
        guard let ch = source.getOrNone(index) else {
            return nil
        }
        index = source.index(after: index)
        
        switch ch {
        case Character("\r"):
            switch source.getOrNone(index) {
            case .some(Character("\n")):
                index = source.index(after: index)
                return .newline("\r\n")
            default:
                return .newline("\r")
            }
        case Character("\n"):
            return .newline("\n")
        case Character("%"):
            switch source.getOrNone(index) {
            case .some(Character("%")):
                // escaped
                index = source.index(after: index)
                return .char("%")
            case .some(Character("{")):
                index = source.index(after: index)
                return .codeOpen
            default:
                return .codeLine
            }
        case Character("$"):
            switch source.getOrNone(index) {
            case .some(Character("$")):
                // escaped
                index = source.index(after: index)
                return .char("$")
            case .some(Character("{")):
                index = source.index(after: index)
                return .substOpen
            default:
                return .char("$")
            }
        case Character("{"):
            return .leftBrace
        case Character("}"):
            switch source.getOrNone(index) {
            case .some(Character("%")):
                index = source.index(after: index)
                return .codeClose
            default:
                return .rightBrace
            }
        default:
            return .char(String(ch))
        }
    }
    
    private var source: String!
    private var index: String.Index!
}
