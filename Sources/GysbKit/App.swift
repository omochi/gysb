//
//  App.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

import Foundation

public class App {
    enum Mode {
        case help
        case parse
        case macro
        case compile
        case render
    }
    
    struct Option {
        var mode: Mode
        var path: String?
    }
    
    public init() {}
    
    public func main() -> Int32 {
        do {
            return try _main()
        } catch let e {
            print("[Error] \(e)")
            return EXIT_FAILURE
        }
    }
    
    func _main() throws -> Int32 {
        let option: Option
        do {
            option = try parseCommandLine(args: CommandLine.arguments)
        } catch let e {
            print("[Error] \(e)")
            print()
            printHelp()
            return EXIT_FAILURE
        }
        
        if option.mode == .help {
            printHelp()
            return EXIT_SUCCESS
        }
        
        let driver = Driver.init(path: option.path!)
        try driver.run(to: .init(appMode: option.mode))
        
        return EXIT_SUCCESS
    }
    
    private func parseCommandLine(args: [String]) throws -> Option {
        var index = 1
        
        if index >= args.count {
            throw Error(message: "invalid args")
        }

        let mode: Mode
        var path: String? = nil
        
        var arg = args[index]
        index += 1
        
        switch arg {
        case "--help":
            mode = .help
        case "--parse":
            mode = .parse
        case "--macro":
            mode = .macro
        case "--compile":
            mode = .compile
        case "--render":
            mode = .render
        default:
            if arg.count > 2 && String(arg[..<arg.index(arg.startIndex, offsetBy: 2)]) == "--" {
                throw Error(message: "unknown option: \(arg)")
            }
            
            index -= 1
            mode = .render
        }
        
        switch mode {
        case .help:
            break
        default:
            if index >= args.count {
                throw Error(message: "path not specified")
            }
            arg = args[index]
            index += 1
            
            path = arg
        }
        
        return Option(mode: mode, path: path)
    }
    
    private func printHelp() {
        let text = """
        Usage: \(CommandLine.arguments[0]) [mode] path
        
        # mode
            --help: print help
            --parse: print AST
            --macro: print macro evaluated AST
            --compile: print compiled Swift
            --render: render template
        """
        print(text)
    }
}
