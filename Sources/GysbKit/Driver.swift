//
//  Driver.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

class Driver {
    enum Stage {
        case parse
        case macro
        case compile
        case render
        
        init(appMode: App.Mode) {
            switch appMode {
            case .parse:
                self = .parse
            case .macro:
                self = .macro
            case .compile:
                self = .compile
            case .render:
                self = .render
            case .help:
                fatalError("bug")
            }
        }
    }
    
    init(path: String) {
        self.path = path
    }
    
    func run(to stage: Stage) throws {
        let text = try render(to: stage)
        print(text, terminator: "")
    }
    
    func render(to stage: Stage) throws -> String {
        let source = try String(contentsOfFile: path, encoding: .utf8)
        
        var template = try Parser.init(source: source).parse()
        if stage == .parse {
            return template.print()
        }
        
        template = try MacroExecutor.init(template: template, path: path).execute()
        if stage == .macro {
            return template.print()
        }
        
        let code = CodeGenerator.init(template: template).generate()
        if stage == .compile {
            return code
        }
        
        let result = try CodeExecutor(code: code, path: path).execute()
        return result
    }
    
    private let path: String
}
