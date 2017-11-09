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
    struct SpecialFuncCall {
        var name: String
        var args: [Any]
    }
    struct IncludeCodeResult {
        var path: String
    }
    
    init(template: Template,
         path: URL)
    {
        self.template = template
        self.path = path
    }
    
    func execute() throws -> Template {
        joinMacroNodes()
        try processMacro()
        return self.template
    }
    
//    func eval<X: ASTNode>(node: X) throws -> Any {
//        switch node.switcher {
//        case .macroCall(let x):
//            return try evalMacroCall(x)
//        case .macroStringLiteral(let x):
//            return x.string
//        default:
//            throw Error(message: "can not eval this node: \(node)")
//        }
//    }
//
//    func evalMacroCall(_ call: MacroCallNode) throws -> Any {
//        switch call.name {
//        case "include_code":
//            if call.args.count != 1 {
//                throw Error(message: "macro arg num is wrong")
//            }
//            let path = try cast(eval(node: call.args[0]), to: String.self)
//            return IncludeCodeResult(path: path)
//        default:
//            throw Error(message: "undefined macro: \(call.name)")
//        }
//    }
    
    func includeCode(path pattern: String) throws -> [CodeNode] {
        var ret = [CodeNode]()
        
        let from = self.path.deletingLastPathComponent()

        for path in glob(pattern: pattern, in: from.path) {
            let code = try String.init(contentsOfFile: path, encoding: .utf8) + "\n"
            ret.append(CodeNode(code: code))
        }
        return ret
    }
    
    private func joinMacroNodes() {
        var index = 0
        var newChildren = [AnyASTNode]()
        
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
        
        self.template = Template(children: newChildren)
    }
    
    private func processMacro() throws {
        var index = 0
        var newChildren = [AnyASTNode]()
        
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
        
        self.template = Template(children: newChildren)
    }
    
    private func evalMacroNode(_ macro: MacroNode) throws -> [AnyASTNode] {
        var ret = [AnyASTNode]()
        let interpreter = Interpreter(source: macro.code)
        interpreter.functions["include_code"] = { (args: [Any]) -> Any in
            guard args.count == 1 else {
                throw Error(message: "wrong arg num")
            }
            let path = try cast(args[0], to: String.self)
            let codes = try self.includeCode(path: path)
            ret.append(contentsOf: codes.map { AnyASTNode($0) })
            return ()
        }
        try interpreter.run()
        return ret
    }
    
    private var template: Template
    private let path: URL
}
