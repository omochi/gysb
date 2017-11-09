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
    func visit(macro: MacroNode) throws -> VisitResult
    func visit(template: Template) throws -> VisitResult
}

protocol ASTVisitor : ASTThrowableVisitor {
}


