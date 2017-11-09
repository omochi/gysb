//
//  CodeGenerator.swift
//  gysbPackageDescription
//
//  Created by omochimetaru on 2017/11/08.
//

import Foundation

class CodeGenerator : ASTVisitor {
    init(template: Template) {
        self.template = template
    }
    
    func generate() -> String {
        code = ""
        
        emitStdLib()
        
        assertNotThrow("Generator never fails") {
            template.accept(visitor: self)
        }
        
        return code
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
        emit("write(\(literalCode))\n")
    }
    
    func visit(code codeNode: CodeNode) {
        emit(codeNode.code)
    }
    
    func visit(subst: SubstNode) {
        emit("write(String(describing: \(subst.code)))\n")
    }
    
    func visit(macroCall: MacroCallNode) {
        emit("// \(macroCall)\n")
    }
    
    func visit(macroStringLiteral: MacroStringLiteralNode) {
         emit("// \(macroStringLiteral)\n")
    }
    
    private func emitStdLib() {
        emit("""
func write(_ s: String) {
    print(s, terminator: "")
}

""")
    }
    
    private func emit(_ code: String) {
        self.code.append(code)
    }
    
    private let template: Template
    private var code: String = ""
}
