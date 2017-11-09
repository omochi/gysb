//
//  RenderCodeGenerator.swift
//  GysbKit
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation
import GysbBase

class TemplateCodeGenerator {
    typealias VisitResult = Void
    
    init(template: Template, emit: @escaping (String) -> Void) {
        self.template = template
        self._emit = emit
    }
    
    func generate() {
        process(template)
    }
    
    private func process(_ node: ASTNode) {
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
        }
    }
    
    private func emit(_ code: String) {
        _emit("    " + code)
    }
    
    private let template: Template
    private let _emit: (String) -> Void
}
