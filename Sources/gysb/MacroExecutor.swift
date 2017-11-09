//
//  MacroExecutor.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

// convert AST
class MacroExecutor : ASTThrowableVisitor {
    typealias VisitResult = AnyASTNode
    
    init(template: Template) {
        self.template = template
    }
    
    func execute() throws -> Template {
        return try template.acceptOrThrow(visitor: self).downCast(to: Template.self)
    }
    
    func visit(nop: NopNode) -> AnyASTNode {
        return AnyASTNode(nop)
    }
    
    func visit(text: TextNode) -> AnyASTNode {
        return AnyASTNode(text)
    }
    
    func visit(code: CodeNode) -> AnyASTNode {
        return AnyASTNode(code)
    }
    
    func visit(subst: SubstNode) -> AnyASTNode {
        return AnyASTNode(subst)
    }
    
    func visit(macroCall: MacroCallNode) throws -> AnyASTNode {
        switch macroCall.name {
        case "include_code":
            // todo
            break
        default:
            throw Error(message: "undefined macro: \(macroCall.name)")
        }
        
        return AnyASTNode(macroCall)
    }
    
    func visit(macroStringLiteral: MacroStringLiteralNode) -> AnyASTNode {
        return AnyASTNode(macroStringLiteral)
    }
    
    func visit(template: Template) throws -> AnyASTNode {
        var newChildren = [AnyASTNode]()
        for child in template.children {
            let newChild = try child.acceptOrThrow(visitor: self)
            newChildren.append(newChild)
        }
        
        return AnyASTNode(Template(children: newChildren))
    }
    
    
    private let template: Template
}
