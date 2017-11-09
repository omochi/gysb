//
//  MacroExecutor.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

// convert AST
class MacroExecutor : ASTVisitor {
    typealias VisitResult = AnyASTNode
    
    init(template: Template) {
        self.template = template
    }
    
    func execute() -> Template {
        return try! template.accept(visitor: self).downCast(to: Template.self)
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
    
    func visit(macroCall: MacroCallNode) -> AnyASTNode {
        switch macroCall.name {
        case "include_code":
            // todo
            break
        default:
            // todo: throw
            fatalError("undefined macro: \(macroCall.name)")
        }
        
        return AnyASTNode(macroCall)
    }
    
    func visit(macroStringLiteral: MacroStringLiteralNode) -> AnyASTNode {
        return AnyASTNode(macroStringLiteral)
    }
    
    func visit(template: Template) -> AnyASTNode {
        var newChildren = [AnyASTNode]()
        for child in template.children {
            let newChild = child.accept(visitor: self)
            newChildren.append(newChild)
        }
        
        return AnyASTNode(Template(children: newChildren))
    }
    
    
    private let template: Template
}
