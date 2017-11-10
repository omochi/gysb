//
//  CodeGenerator.swift
//  gysbPackageDescription
//
//  Created by omochimetaru on 2017/11/08.
//

import Foundation

class CodeGenerator {
    init(state: Driver.State, entryIndex: Int) {
        self.state = state
        self.entryIndex = entryIndex
    }
    
    func generate() -> String {
        if buildWork.config.includesFiles.count > 0 {
            emit("""
                import \(state.includeFilesTargetName)
                
                
                """)
        }
        
        emit("""
            var gysb_result: String = ""

            func gysb_write(_ s: String) {
                gysb_result.append(s)
            }

            """)
        emit("\n")
        
        let template = entry.template!
        
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
    private var entry: Driver.State.Entry {
        get {
            return state.entries[entryIndex]
        }
        set {
            state.entries[entryIndex] = newValue
        }
    }
    private var buildWork: Driver.State.BuildWork {
        get {
            let iw = state.buildWorkIndexForEntry(index: entryIndex)!
            return state.buildWorks[iw]
        }
        set {
            let iw = state.buildWorkIndexForEntry(index: entryIndex)!
            state.buildWorks[iw] = newValue
        }
    }
    private let state: Driver.State
    private let entryIndex: Int
}
