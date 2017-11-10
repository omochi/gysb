//
//  AST.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

import GysbBase

public protocol ASTNode : CustomStringConvertible {
    var switcher: ASTNodeSwitcher { get }
}

extension ASTNode {
    public func print() -> String {
        return ASTPrinter(node: AnyASTNode(self)).print()
    }
}

public enum ASTNodeSwitcher {
    case nop(NopNode)
    case text(TextNode)
    case code(CodeNode)
    case subst(SubstNode)
    case macro(MacroNode)
    case template(Template)
}

public struct AnyASTNode : ASTNode {
    public init<X: ASTNode>(_ base: X) {
        self.base = base
    }
    
    public var switcher: ASTNodeSwitcher {
        return base.switcher
    }
    
    public var description: String {
        return base.description
    }
    
    public func downCast<T>(to: T.Type) throws -> T {
        return try cast(base, to: T.self)
    }
    
    private let base: ASTNode
}

public struct NopNode : ASTNode {
    public var switcher: ASTNodeSwitcher {
        return .nop(self)
    }
    
    public var description: String {
        return "Nop()"
    }
}

public struct TextNode : ASTNode {
    public var text: String
    
    public var switcher: ASTNodeSwitcher {
        return .text(self)
    }
    
    public var description: String {
        return "Text(\(escapeToSwiftLiteral(text: text)))"
    }
}

public struct CodeNode : ASTNode {
    public var code: String
    
    public var switcher: ASTNodeSwitcher {
        return .code(self)
    }
    
    public var description: String {
        return "Code(\(escapeToSwiftLiteral(text: code)))"
    }
}

public struct SubstNode: ASTNode {
    public var code: String
    
    public var switcher: ASTNodeSwitcher {
        return .subst(self)
    }
    
    public var description: String {
        return "Code(\(escapeToSwiftLiteral(text: code)))"
    }
}

public struct MacroNode: ASTNode {
    public var code: String
    
    public var switcher: ASTNodeSwitcher {
        return .macro(self)
    }
    
    public var description: String {
        return "Macro(\(escapeToSwiftLiteral(text: code)))"
    }
}

public struct Template : ASTNode {
    public var children: [AnyASTNode] = []
    
    public var switcher: ASTNodeSwitcher {
        return .template(self)
    }    
    
    public var description: String {
        return "Template(#children=\(children.count))"
    }
}

