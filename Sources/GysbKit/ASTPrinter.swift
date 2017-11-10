//
//  ASTPrinter.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

public class ASTPrinter {
    public init(node: AnyASTNode) {
        self.node = node
    }
    
    public func print() -> String {
        process(node)
        return output
    }
    
    private func process<X: ASTNode>(_ node: X) {
        switch node.switcher {
        case .nop(let nop):
            write(nop.description)
        case .text(let text):
            write(text.description)
        case .code(let code):
            write(code.description)
        case .subst(let subst):
            write(subst.description)
        case .macro(let macro):
            write(macro.description)
        case .template(let template):
            write("Template {")
            indent += 1
            template.children.forEach { child in
                process(child)
            }
            indent -= 1
            write("}")
        }
    }
    
    private func write(_ string: String) {
        output += String.init(repeating: "  ", count: indent)
        output += string
        output += "\n"
    }
    
    private let node: AnyASTNode
    private var indent: Int = 0
    private var output: String = ""
}
