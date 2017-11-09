//
//  RenderCodeGenerator.swift
//  GysbKit
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

class TemplateCodeGenerator : ASTVisitor {
    typealias VisitResult = Void
    
    init(template: Template, emit: @escaping (String) -> Void) {
        self.template = template
        self._emit = emit
    }
    
    func generate() {
        template.accept(visitor: self)
    }
    
    func visit(template: Template) throws {
        template.children.forEach { child in
            child.accept(visitor: self)
        }
    }
    
    func visit(nop: NopNode) {
        emit("// \(nop)\n")
    }
    
    func visit(text: TextNode) {
        let literalCode = "\"" + escapeToSwiftLiteral(text: text.text) + "\""
        emit("gysb_write(\(literalCode))\n")
    }
    
    func visit(code codeNode: CodeNode) {
        emit(codeNode.code)
    }
    
    func visit(subst: SubstNode) {
        emit("gysb_write(String(describing: \(subst.code)))\n")
    }
    
    func visit(macroCall: MacroCallNode) {
        emit("// \(macroCall)\n")
    }
    
    func visit(macroStringLiteral: MacroStringLiteralNode) {
        emit("// \(macroStringLiteral)\n")
    }
   
    private func emit(_ code: String) {
        _emit("    " + code)
    }
    
    private let template: Template
    private let _emit: (String) -> Void
}
