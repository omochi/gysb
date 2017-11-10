//
//  MacroExecutor.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation
import GysbBase
import GysbMacroLib

// convert AST
class MacroProcessor {
    init(state: Driver.State, index: Int) {
        self.state = state
        self.stateIndex = index
    }
    
    func execute() throws {
        joinMacroNodes()
        try processMacro()
    }
    
    private func joinMacroNodes() {
        var index = 0
        var newChildren = [AnyASTNode]()
        
        let template = self.stateEntry.template!
        
        while true {
            if index >= template.children.count {
                break
            }
            
            let child = template.children[index]
            index += 1
            
            if let _ = try? child.downCast(to: MacroNode.self) {
                index -= 1
                var macroCode: String = ""
                while true {
                    if index >= template.children.count {
                        break
                    }
                    
                    let child = template.children[index]
                    index += 1
                    
                    if let macro = try? child.downCast(to: MacroNode.self) {
                        macroCode += macro.code
                    } else {
                        index -= 1
                        break
                    }
                }
                newChildren.append(AnyASTNode(MacroNode(code: macroCode)))
            } else {
                newChildren.append(child)
            }
        }
        
        self.stateEntry.template = Template(children: newChildren)
    }
    
    private func processMacro() throws {
        var index = 0
        var newChildren = [AnyASTNode]()
        
        let template = self.stateEntry.template!
        
        while true {
            if index >= template.children.count {
                break
            }
            
            let child = template.children[index]
            index += 1
            
            if let macro = try? child.downCast(to: MacroNode.self) {
                let nodes = try evalMacroNode(macro)
                newChildren.append(contentsOf: nodes)
            } else {
                newChildren.append(child)
            }
        }
        
        self.stateEntry.template = Template(children: newChildren)
    }
    
    private func evalMacroNode(_ macro: MacroNode) throws -> [AnyASTNode] {
        var ret = [AnyASTNode]()
        let ipr = Interpreter(source: macro.code)
        
        ipr.registerFunction(name: "include_code") { (path: String) -> Void in
            let codes = try self.includeCode(path: path)
            ret.append(contentsOf: codes.map { AnyASTNode($0) })
            return ()
        }

//        ipr.registerFunction(name: "swift_config") { (path: String) -> Void in
//            let path = resolvePath(URL.init(fileURLWithPath: path), in: self.basePath)
//            self.stateEntry.swiftConfig = path
//        }
        
        try ipr.run()
        return ret
    }
    
    private func includeCode(path pattern: String) throws -> [CodeNode] {
        var ret = [CodeNode]()
        
        for path in glob(pattern: pattern, in: basePath) {
            let code = try String.init(contentsOf: path, encoding: .utf8) + "\n"
            ret.append(CodeNode(code: code))
        }
        return ret
    }

    private var stateEntry: Driver.State.Entry {
        get {
            return state.entries[stateIndex]
        }
        set {
            state.entries[stateIndex] = newValue
        }
    }
    
    private var basePath: URL {
        return stateEntry.path.deletingLastPathComponent()
    }
    
    private let state: Driver.State
    private let stateIndex: Int
}
