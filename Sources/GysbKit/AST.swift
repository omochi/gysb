//
//  AST.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

import GysbBase

protocol ASTNode : CustomStringConvertible {
    var switcher: ASTNodeSwitcher { get }
}

extension ASTNode {
    func print() -> String {
        return ASTPrinter(node: AnyASTNode(self)).print()
    }
}

enum ASTNodeSwitcher {
    case nop(NopNode)
    case text(TextNode)
    case code(CodeNode)
    case subst(SubstNode)
    case macro(MacroNode)
    case template(Template)
}

struct AnyASTNode : ASTNode {
    init<X: ASTNode>(_ base: X) {
        self.base = base
    }
    
    var switcher: ASTNodeSwitcher {
        return base.switcher
    }
    
    var description: String {
        return base.description
    }
    
    func downCast<T>(to: T.Type) throws -> T {
        return try cast(base, to: T.self)
    }
    
    private let base: ASTNode
}

struct NopNode : ASTNode {
    var switcher: ASTNodeSwitcher {
        return .nop(self)
    }
    
    var description: String {
        return "Nop()"
    }
}

struct TextNode : ASTNode {
    var text: String
    
    var switcher: ASTNodeSwitcher {
        return .text(self)
    }
    
    var description: String {
        return "Text(\(escapeToSwiftLiteral(text: text)))"
    }
}

struct CodeNode : ASTNode {
    var code: String
    
    var switcher: ASTNodeSwitcher {
        return .code(self)
    }
    
    var description: String {
        return "Code(\(escapeToSwiftLiteral(text: code)))"
    }
}

struct SubstNode: ASTNode {
    var code: String
    
    var switcher: ASTNodeSwitcher {
        return .subst(self)
    }
    
    var description: String {
        return "Code(\(escapeToSwiftLiteral(text: code)))"
    }
}

struct MacroNode: ASTNode {
    var code: String
    
    var switcher: ASTNodeSwitcher {
        return .macro(self)
    }
    
    var description: String {
        return "Macro(\(escapeToSwiftLiteral(text: code)))"
    }
}

struct Template : ASTNode {
    var children: [AnyASTNode] = []
    
    var switcher: ASTNodeSwitcher {
        return .template(self)
    }    
    
    var description: String {
        return "Template(#children=\(children.count))"
    }
}

