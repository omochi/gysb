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
        case compile
        case render
        
        public func toDriverStage() -> Driver.Stage {
            switch self {
            case .parse: return .parse
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
            let option: Option = try parseCommandLine(args: CommandLine.arguments)
            
            switch option {
            case .help:
                printHelp()
                return EXIT_SUCCESS
            case .driver(let opt):
                let driver = Driver.init(option: opt)
                try driver.run()
                return EXIT_SUCCESS
            }
        } catch let e {
            switch e {
            case DriverError.invalidOption:
                print(e)
                print()
                printHelp()
                return EXIT_FAILURE
            default:
                print("\(e)")
                return EXIT_FAILURE
            }
        }
    }
    
    private func parseCommandLine(args: [String]) throws -> Option {
        var index = 1
        
        var option = Driver.Option()
        var mode: Mode?
        
        while true {
            if index >= args.count {
                throw DriverError.invalidOption("no mode specified")
            }

            let arg = args[index]
            index += 1
            
            switch arg {
            case "--help":
                mode = .help
            case "--parse":
                mode = .parse
            case "--compile":
                mode = .compile
            case "--render":
                mode = .render
            case "--write":
                option.writeOnSame = true
            case "--source-dirs":
                option.sourceDirs = true
            default:
                if arg.count > 2 && String(arg[..<arg.index(arg.startIndex, offsetBy: 2)]) == "--" {
                    throw DriverError.invalidOption("unknown option: \(arg)")
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
        
        option.stage = mode!.toDriverStage()

        if index >= args.count {
            throw DriverError.invalidOption("path not specified")
        }
        
        for arg in args[index...] {
            option.paths.append(arg)
        }
        
        return .driver(option)
    }
    
    private func printHelp() {
        let text = """
        Usage: \(CommandLine.arguments[0]) [mode] [flags] paths...
        
        # mode
            --help: print help
            --parse: print AST
            --compile: print compiled Swift
            --render: render template (default)
        
        # flags
            --write: write output on same directory (extension removed)
            --source-dirs: paths means directory and search *.gysb (automatically enable `--write`)
        
        """
        print(text)
    }
}
