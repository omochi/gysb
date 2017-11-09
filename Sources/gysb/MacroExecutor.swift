//
//  MacroExecutor.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

// convert AST
class MacroExecutor : ASTThrowableVisitor {
    typealias VisitResult = AnyASTNode
    
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
        return try template.acceptOrThrow(visitor: self).downCast(to: Template.self)
    }
    
    func visit(nop: NopNode) -> AnyASTNode {
        return AnyASTNode(nop)
    }
    
    func visit(text: TextNode) -> AnyASTNode {
        return AnyASTNode(text)
    }
    
    func visit(code: CodeNode) -> AnyASTNode {
        return AnyASTNode(code)
    }
    
    func visit(subst: SubstNode) -> AnyASTNode {
        return AnyASTNode(subst)
    }
    
    func visit(macroCall: MacroCallNode) throws -> AnyASTNode {
        let ret = try evalMacroCall(macroCall)
        
        switch ret {
        case let ret as IncludeCodeResult:
            let codeNode: CodeNode = try includeCode(path: ret.path)
            return AnyASTNode(codeNode)
        default:
            throw Error(message: "invalid macro call: \(macroCall)")
        }
    }
    
    func visit(macroStringLiteral: MacroStringLiteralNode) -> AnyASTNode {
        return AnyASTNode(macroStringLiteral)
    }
    
    func visit(template: Template) throws -> AnyASTNode {
        var newChildren = [AnyASTNode]()
        for child in template.children {
            let newChild = try child.acceptOrThrow(visitor: self)
            newChildren.append(newChild)
        }
        
        return AnyASTNode(Template(children: newChildren))
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
    
    func includeCode(path: String) throws -> CodeNode {
        let from = URL.init(fileURLWithPath: self.path).deletingLastPathComponent()
        let path = resolvePath(path, in: from.relativePath)
        let code = try String.init(contentsOfFile: path, encoding: .utf8) + "\n"
        return CodeNode(code: code)
    }
    
    private let template: Template
    private let path: String
}
