//
//  Compiler.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

import Foundation

// it compile template to swift code.
class Compiler {    
    func compile(file: String) throws -> String {
        let source = try String.init(contentsOfFile: file, encoding: .utf8)
        return try compile(source: source)
    }
    
    func compile(source: String) throws -> String {
        let parser = Parser(source: source)
        let template = try parser.parse()

//        template.print()
        
        let generator = CodeGenerator()
        let code = generator.run(template: template)
        
//        print(code)
        
        return code
    }
}
