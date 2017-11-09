//
//  ASTVisitor.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

protocol ASTVisitor {
    associatedtype VisitResult
    func visit(nop: NopNode) -> VisitResult
    func visit(text: TextNode) -> VisitResult
    func visit(code: CodeNode) -> VisitResult
    func visit(subst: SubstNode) -> VisitResult
    func visit(macroCall: MacroCallNode) -> VisitResult
    func visit(macroStringLiteral: MacroStringLiteralNode) -> VisitResult
    func visit(template: Template) -> VisitResult
}

extension ASTVisitor where VisitResult == Void {
    func visit(nop: NopNode) {}
    func visit(text: TextNode) {}
    func visit(code: CodeNode) {}
    func visit(subst: SubstNode) {}
    func visit(macroCall: MacroCallNode) {}
    func visit(macroStringLiteral: MacroStringLiteralNode) {}
    func visit(template: Template) {}
}
