//
//  Compiler.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

import Foundation

// it compile template to swift code.
class Compiler {
    convenience init(path: String) throws {
        let source = try String(contentsOfFile: path, encoding: .utf8)
        self.init(source: source, path: path)
    }
    
    init(source: String, path: String) {
        self.source = source
        self.path = path
    }
    
    func compile() throws -> String {
        let parser = Parser(source: source)
        var template = try parser.parse()

        template.print()
        
        let macroExecutor = MacroExecutor(template: template, path: path)
        template = try macroExecutor.execute()
        
        template.print()
        
        let generator = CodeGenerator(template: template)
        let code = generator.generate()
        
//        print(code)
        
        return code
    }
    
    private let source: String
    private let path: String
}
