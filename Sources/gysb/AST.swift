//
//  AST.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

protocol ASTNode {
    func accept(visitor: ASTVisitor)
}

extension ASTNode {
    func print() {
        accept(visitor: ASTPrinter())
    }
}

struct AnyASTNode : ASTNode {
    init<X: ASTNode>(_ base: X) {
        self.base = base
    }
    
    func accept(visitor: ASTVisitor) {
        base.accept(visitor: visitor)
    }
    
    private let base: ASTNode
}

struct NopNode : ASTNode {
    func accept(visitor: ASTVisitor) {
        visitor.visit(nop: self)
    }
}

struct TextNode : ASTNode {
    var text: String
    
    func accept(visitor: ASTVisitor) {
        visitor.visit(text: self)
    }
}

struct CodeNode : ASTNode {
    var code: String
    
    func accept(visitor: ASTVisitor) {
        visitor.visit(code: self)
    }
}

struct SubstNode: ASTNode {
    var code: String
    
    func accept(visitor: ASTVisitor) {
        visitor.visit(subst: self)
    }
}

struct Template : ASTNode {
    var children: [AnyASTNode] = []
    
    func accept(visitor: ASTVisitor) {
        visitor.visit(template: self)
    }
}

