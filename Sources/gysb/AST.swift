//
//  AST.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

protocol ASTNode : CustomStringConvertible {
    func acceptOrThrow<V: ASTThrowableVisitor>(visitor: V) throws -> V.VisitResult
    
    func accept<V: ASTVisitor>(visitor: V) -> V.VisitResult
}

extension ASTNode {
    func accept<V: ASTVisitor>(visitor: V) -> V.VisitResult {
        return try! acceptOrThrow(visitor: visitor)
    }
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
    
    func acceptOrThrow<V: ASTThrowableVisitor>(visitor: V) throws -> V.VisitResult {
        return try base.acceptOrThrow(visitor: visitor)
    }
    
    var description: String {
        return base.description
    }
    
    func downCast<T>(to: T.Type) throws -> T {
        guard let t = base as? T else {
            throw Error(message: "ASTNode downcast failed (type=\(type(of: base)), to=\(to))")
        }
        return t
    }
    
    private let base: ASTNode
}

struct NopNode : ASTNode {
    func acceptOrThrow<V: ASTThrowableVisitor>(visitor: V) throws -> V.VisitResult {
        return try visitor.visit(nop: self)
    }
    
    var description: String {
        return "Nop()"
    }
}

struct TextNode : ASTNode {
    var text: String
    
    func acceptOrThrow<V: ASTThrowableVisitor>(visitor: V) throws -> V.VisitResult {
        return try visitor.visit(text: self)
    }
    
    var description: String {
        return "Text(\(escapeToSwiftLiteral(text: text)))"
    }
}

struct CodeNode : ASTNode {
    var code: String
    
    func acceptOrThrow<V: ASTThrowableVisitor>(visitor: V) throws -> V.VisitResult {
        return try visitor.visit(code: self)
    }
    
    var description: String {
        return "Code(\(escapeToSwiftLiteral(text: code)))"
    }
}

struct SubstNode: ASTNode {
    var code: String
    
    func acceptOrThrow<V: ASTThrowableVisitor>(visitor: V) throws -> V.VisitResult {
        return try visitor.visit(subst: self)
    }
    
    var description: String {
        return "Code(\(escapeToSwiftLiteral(text: code)))"
    }
}

struct MacroCallNode: ASTNode {
    var name: String
    var args: [AnyASTNode]
    
    func acceptOrThrow<V: ASTThrowableVisitor>(visitor: V) throws -> V.VisitResult {
        return try visitor.visit(macroCall: self)
    }
    
    var description: String {
        return "MacroCall(\(name))"
    }
}

struct MacroStringLiteralNode: ASTNode {
    var string: String
    
    func acceptOrThrow<V: ASTThrowableVisitor>(visitor: V) throws -> V.VisitResult {
        return try visitor.visit(macroStringLiteral: self)
    }
    
    var description: String {
        return "MacroStringLiteral(\(escapeToSwiftLiteral(text: string)))"
    }
}

struct Template : ASTNode {
    var children: [AnyASTNode] = []
    
    func acceptOrThrow<V: ASTThrowableVisitor>(visitor: V) throws -> V.VisitResult {
        return try visitor.visit(template: self)
    }
    
    var description: String {
        return "Template(#children=\(children.count))"
    }
}

