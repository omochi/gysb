//
//  ASTVisitor.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

protocol ASTThrowableVisitor {
    associatedtype VisitResult
    func visit(nop: NopNode) throws -> VisitResult
    func visit(text: TextNode) throws -> VisitResult
    func visit(code: CodeNode) throws -> VisitResult
    func visit(subst: SubstNode) throws -> VisitResult
    func visit(macroCall: MacroCallNode) throws -> VisitResult
    func visit(macroStringLiteral: MacroStringLiteralNode) throws -> VisitResult
    func visit(template: Template) throws -> VisitResult
}

extension ASTThrowableVisitor where VisitResult == Void {
    func visit(nop: NopNode) throws {}
    func visit(text: TextNode) throws {}
    func visit(code: CodeNode) throws {}
    func visit(subst: SubstNode) throws {}
    func visit(macroCall: MacroCallNode) throws {}
    func visit(macroStringLiteral: MacroStringLiteralNode) throws  {}
    func visit(template: Template) throws {}
}

protocol ASTVisitor : ASTThrowableVisitor {
}


