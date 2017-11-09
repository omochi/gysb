//
//  AST.swift
//  GysbMacroLib
//
//  Created by omochimetaru on 2017/11/10.
//

import Foundation

protocol ASTNode : CustomStringConvertible {
    
    var switcher: ASTNodeSwitcher { get }
}

enum ASTNodeSwitcher {
    case call(CallNode)
    case stringLiteral(StringLiteralNode)
}

struct AnyASTNode : ASTNode {
    init<X: ASTNode>(_ base: X) {
        self.base = base
    }
    
    var description: String {
        return base.description
    }
    
    var switcher: ASTNodeSwitcher {
        return base.switcher
    }
    
    private var base: ASTNode
}

struct CallNode : ASTNode {
    var name: String
    var args: [AnyASTNode]
    
    var description: String {
        return "Call(\(name))"
    }
    
    var switcher: ASTNodeSwitcher {
        return .call(self)
    }
}

struct StringLiteralNode : ASTNode {
    var string: String
    
    var description: String {
        return "StringLiteral(\(string))"
    }
    
    var switcher: ASTNodeSwitcher {
        return .stringLiteral(self)
    }
}
