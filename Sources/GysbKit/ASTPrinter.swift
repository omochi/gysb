//
//  ASTPrinter.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

class ASTPrinter : ASTVisitor {
    func visit(nop: NopNode) {
        write(nop.description)
    }
    
    func visit(text: TextNode) {
        write(text.description)
    }
    
    func visit(code: CodeNode) {
        write(code.description)
    }
    
    func visit(subst: SubstNode) {
        write(subst.description)
    }
    
    func visit(macro: MacroNode) throws -> () {
        write(macro.description)
    }    
    
    func visit(template: Template) throws {
        write("Template {")
        indent += 1
        template.children.forEach { child in
            child.accept(visitor: self)
        }
        indent -= 1
        write("}")
    }
    
    func write(_ string: String) {
        output += String.init(repeating: "  ", count: indent)
        output += string
        output += "\n"
    }
    
    var indent: Int = 0
    var output: String = ""
}
