//
//  ASTVisitor.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

protocol ASTVisitor {
    func visit(nop: NopNode)
    func visit(text: TextNode)
    func visit(code: CodeNode)
    func visit(subst: SubstNode)
    func visit(macroCall: MacroCallNode)
    func visit(macroStringLiteral: MacroStringLiteralNode)
    func visit(template: Template)
}

extension ASTVisitor {
    func visit(nop: NopNode) {}
    func visit(text: TextNode) {}
    func visit(code: CodeNode) {}
    func visit(subst: SubstNode) {}
    func visit(macroCall: MacroCallNode) {}
    func visit(macroStringLiteral: MacroStringLiteralNode) {}
    func visit(template: Template) {}
}
