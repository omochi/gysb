//
//  CodeGenerator.swift
//  gysbPackageDescription
//
//  Created by omochimetaru on 2017/11/08.
//

import Foundation

class CodeGenerator : ASTVisitor {
    func run(template: Template) -> String {
        code = ""
        
        emitStdLib()
        template.accept(visitor: self)
        return code
    }
    
    func visit(template: Template) {
        template.children.forEach { child in
            child.accept(visitor: self)
        }
    }
    
    func visit(nop: NopNode) {
        code.append("// nop\n")
    }
    
    func visit(text: TextNode) {
        let literalCode = "\"" + escape(text: text.text) + "\""
        code.append("write(\(literalCode))\n")
    }
    
    func visit(code codeNode: CodeNode) {
        code.append(codeNode.code)
    }
    
    func visit(subst: SubstNode) {
        code.append("write(String(describing: \(subst.code)))\n")
    }
    
    private func escape(text: String) -> String {
        var s = text
        s = s.replacingOccurrences(of: "\\", with: "\\\\")
        s = s.replacingOccurrences(of: "\"", with: "\\\"")
        s = s.replacingOccurrences(of: "\t", with: "\\t")
        s = s.replacingOccurrences(of: "\n", with: "\\n")
        s = s.replacingOccurrences(of: "\r", with: "\\r")
        return s
    }
    
    private func emitStdLib() {
        code.append("""
func write(_ s: String) {
    print(s, terminator: "")
}

""")
    }
    
    private var code: String = ""
}
