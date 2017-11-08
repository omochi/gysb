//
//  AST.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

protocol ASTNode : CustomStringConvertible {
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
    
    var description: String {
        return base.description
    }
    
    private let base: ASTNode
}

struct NopNode : ASTNode {
    func accept(visitor: ASTVisitor) {
        visitor.visit(nop: self)
    }
    
    var description: String {
        return "Nop()"
    }
}

struct TextNode : ASTNode {
    var text: String
    
    func accept(visitor: ASTVisitor) {
        visitor.visit(text: self)
    }
    
    var description: String {
        return "Text(\(escapeToSwiftLiteral(text: text)))"
    }
}

struct CodeNode : ASTNode {
    var code: String
    
    func accept(visitor: ASTVisitor) {
        visitor.visit(code: self)
    }
    
    var description: String {
        return "Code(\(escapeToSwiftLiteral(text: code)))"
    }
}

struct SubstNode: ASTNode {
    var code: String
    
    func accept(visitor: ASTVisitor) {
        visitor.visit(subst: self)
    }
    
    var description: String {
        return "Code(\(escapeToSwiftLiteral(text: code)))"
    }
}

struct Template : ASTNode {
    var children: [AnyASTNode] = []
    
    func accept(visitor: ASTVisitor) {
        visitor.visit(template: self)
    }
    
    var description: String {
        return "Template(#children=\(children.count))"
    }
}

