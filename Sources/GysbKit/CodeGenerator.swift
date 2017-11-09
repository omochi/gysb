//
//  CodeGenerator.swift
//  gysbPackageDescription
//
//  Created by omochimetaru on 2017/11/08.
//

import Foundation

class CodeGenerator {
    init(state: Driver.State) {
        self.state = state
    }
    
    func generate() -> String {
        for i in 0..<state.entries.count {
            emitTemplateRender(template: state.entries[i].template!, id: state.entries[i].codeID!)
        }        
        emitMain()
        return code
    }
    
    private func emitTemplateRender(template: Template, id: String) {
        emit("""
            func gysb_\(id)_render() -> String {
                var gysb_result: String = ""
                func gysb_write(_ s: String) {
                    gysb_result.append(s)
                }
            
            """)
        let generator = TemplateCodeGenerator(template: template, emit: self.emit)
        generator.generate()
        emit("""

                return gysb_result
            }

            """)
        emit("\n")
    }
    
    private func emitMain() {
        emit("let gysb_main_result: String = {\n")
        emit("    switch CommandLine.arguments[1] {\n\n")
        for i in 0..<state.entries.count {
            let id = state.entries[i].codeID!
            emit("    case \"\(id)\":\n")
            emit("        return gysb_\(id)_render()\n")
            emit("\n")
        }
        emit("    default:\n")
        emit("        fatalError(\"invalid id\")\n")
        emit("    }\n")
        emit("}()\n")
        emit("\n")
        emit("print(gysb_main_result, terminator: \"\")\n")
    }
    
    func emit(_ code: String) {
        self.code.append(code)
    }
    
    
    private var code: String = ""
    
    private let state: Driver.State
}
