//
//  App.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

import Foundation
import GysbBase

public class App {
    public enum Mode {
        case help
        case parse
        case macro
        case compile
        case render
        
        public func toDriverStage() -> Driver.Stage {
            switch self {
            case .parse: return .parse
            case .macro: return .macro
            case .compile: return .compile
            case .render: return .render
            case .help:
                fatalError("invalid")
            }
        }
    }
    
    public enum Option {
        case help
        case driver(Driver.Option)
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
    
    private func _main() throws -> Int32 {
        let option: Option
        do {
            option = try parseCommandLine(args: CommandLine.arguments)
        } catch let e {
            print("[CommandLine Error] \(e)")
            print()
            printHelp()
            return EXIT_FAILURE
        }
        
        switch option {
        case .help:
            printHelp()
            return EXIT_SUCCESS
        case .driver(let opt):
            let driver = Driver.init(option: opt)
            try driver.run()
            return EXIT_SUCCESS
        }
    }
    
    private func parseCommandLine(args: [String]) throws -> Option {
        var index = 1
        
        var mode: Mode? = nil
        var writeOnSame = false
        var paths: [String] = []
        
        while true {
            if index >= args.count {
                throw Error(message: "no mode specified")
            }

            let arg = args[index]
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
            case "--write":
                writeOnSame = true
            default:
                if arg.count > 2 && String(arg[..<arg.index(arg.startIndex, offsetBy: 2)]) == "--" {
                    throw Error(message: "unknown option: \(arg)")
                }
                
                index -= 1
                if mode == nil {
                    mode = .render
                }
            }
            
            if mode != nil {
                break
            }
        }
        
        if mode == .help {
            return .help
        }
        
        if index >= args.count {
            throw Error(message: "path not specified")
        }
        
        for arg in args[index...] {
            paths.append(arg)
        }
        
        switch mode! {
        case .parse, .macro:
            if paths.count >= 2 {
                throw Error(message: "can not specify multiple sources with this mode")
            }
        case .compile:
            break
        case .render:
            if paths.count >= 2 {
                guard writeOnSame else {
                    throw Error(message: "if you specify multiple sources, need to specify `--write`")
                }
            }
        case .help:
            break
        }
    
        var option = Driver.Option()
        option.stage = mode!.toDriverStage()
        option.writeOnSame = writeOnSame
        option.paths = paths
        return .driver(option)
    }
    
    private func printHelp() {
        let text = """
        Usage: \(CommandLine.arguments[0]) [mode] [flags] paths...
        
        # mode
            --help: print help
            --parse: print AST
            --macro: print macro evaluated AST
            --compile: print compiled Swift
            --render: render template (default)
        
        # flags
            --write: write output on same directory (extension removed)
            --source-dirs: paths means directory and search *.gysb
        """
        print(text)
    }
}
