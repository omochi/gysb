//
//  MacroExecutor.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

// convert AST
class MacroExecutor : ASTThrowableVisitor {
    typealias VisitResult = [AnyASTNode]
    
    struct IncludeCodeResult {
        var path: String
    }
    
    init(template: Template,
         path: String)
    {
        self.template = template
        self.path = path
    }
    
    func execute() throws -> Template {
        let ret = try template.acceptOrThrow(visitor: self)
        return try ret[0].downCast(to: Template.self)
    }
    
    func visit(nop: NopNode) -> [AnyASTNode] {
        return []
    }
    
    func visit(text: TextNode) -> [AnyASTNode] {
        return [AnyASTNode(text)]
    }
    
    func visit(code: CodeNode) -> [AnyASTNode] {
        return [AnyASTNode(code)]
    }
    
    func visit(subst: SubstNode) -> [AnyASTNode] {
        return [AnyASTNode(subst)]
    }
    
    func visit(macroCall: MacroCallNode) throws -> [AnyASTNode] {
        let ret = try evalMacroCall(macroCall)
        
        switch ret {
        case let ret as IncludeCodeResult:
            let codeNodes: [CodeNode] = try includeCode(path: ret.path)
            return codeNodes.map { AnyASTNode($0) }
        default:
            throw Error(message: "invalid macro call: \(macroCall)")
        }
    }
    
    func visit(macroStringLiteral: MacroStringLiteralNode) -> [AnyASTNode] {
        return [AnyASTNode(macroStringLiteral)]
    }
    
    func visit(template: Template) throws -> [AnyASTNode] {
        var newChildren = [AnyASTNode]()
        for child in template.children {
            let newChildArray = try child.acceptOrThrow(visitor: self)
            newChildren.append(contentsOf: newChildArray)
        }
        
        return [AnyASTNode(Template(children: newChildren))]
    }

    func eval<X: ASTNode>(node: X) throws -> Any {
        switch node.switcher {
        case .macroCall(let x):
            return try evalMacroCall(x)
        case .macroStringLiteral(let x):
            return x.string
        default:
            throw Error(message: "can not eval this node: \(node)")
        }
    }
    
    func evalMacroCall(_ call: MacroCallNode) throws -> Any {
        switch call.name {
        case "include_code":
            if call.args.count != 1 {
                throw Error(message: "macro arg num is wrong")
            }
            let path = try cast(eval(node: call.args[0]), to: String.self)
            return IncludeCodeResult(path: path)
        default:
            throw Error(message: "undefined macro: \(call.name)")
        }
    }
    
    func includeCode(path pattern: String) throws -> [CodeNode] {
        var ret = [CodeNode]()
        
        let from = URL.init(fileURLWithPath: self.path).deletingLastPathComponent()

        for path in glob(pattern: pattern, in: from.path) {
            let code = try String.init(contentsOfFile: path, encoding: .utf8) + "\n"
            ret.append(CodeNode(code: code))
        }
        return ret
    }
    
    private let template: Template
    private let path: String
}
