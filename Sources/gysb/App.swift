//
//  App.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

import Foundation

class App {
    func main() {
        do {
            try _main()
            exit(EXIT_SUCCESS)
        } catch let e {
            print(String(describing: e))
            exit(EXIT_FAILURE)
        }
    }
    
    func _main() throws {
        var args = CommandLine.arguments
        if args.count < 2 {
            throw Error(message: "input file not specified")
        }
        let inputFile = args[1]
        
        let compiler = try Compiler(path: inputFile)
        
        let code = try compiler.compile()
        
        let executor = CodeExecutor(code: code,
                                    path: inputFile)
        try executor.execute()
    }
}
