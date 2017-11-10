//
//  CodeGenerator.swift
//  gysbPackageDescription
//
//  Created by omochimetaru on 2017/11/08.
//

import Foundation

class CodeGenerator {
    init(state: Driver.State, index: Int) {
        self.state = state
        self.stateIndex = index
    }
    
    func generate() -> String {
        emit("""
            var gysb_result: String = ""

            func gysb_write(_ s: String) {
                gysb_result.append(s)
            }

            """)
        emit("\n")
        
        let template = self.state.entries[self.stateIndex].template!
        
        let tcg = TemplateCodeGenerator(template: template, emit: self.emit)
        tcg.generate()
        
        emit("""

            print(gysb_result, terminator: "")

            """)
        
        return code
    }
    
    private func emit(_ code: String) {
        self.code.append(code)
    }
    
    private var code: String = ""
    
    private let state: Driver.State
    private let stateIndex: Int
}
