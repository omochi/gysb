//
//  RenderCodeGenerator.swift
//  GysbKit
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation
import GysbBase

public class TemplateCodeGenerator {    
    public init(template: Template, emit: @escaping (String) -> Void) {
        self.template = template
        self._emit = emit
    }
    
    public func generate() {
        process(template)
    }
    
    private func process<X: ASTNode>(_ node: X) {
        switch node.switcher {
        case .text(let text):
            let literalCode = "\"" + escapeToSwiftLiteral(text: text.text) + "\""
            emit("gysb_write(\(literalCode))\n")
        case .code(let code):
            emit(code.code)
        case .subst(let subst):
            emit("gysb_write(String(describing: \(subst.code)))\n")
        case .macro(let macro):
            emit("// \(macro)\n")
        case .nop(let nop):
            emit("// \(nop)\n")
        case .template(let template):
            template.children.forEach { child in
                process(child)
            }
            emit("\n")
        }
    }
    
    private func emit(_ code: String) {
        _emit(code)
    }
    
    private let template: Template
    private let _emit: (String) -> Void
}
