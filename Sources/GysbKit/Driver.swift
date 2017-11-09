//
//  Driver.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

class Driver {
    class State {
        struct Entry {
            var path: String
            var destPath: String?
            
            var source: String?
            var template: Template?
            var code: String?
            var rendered: String?
            
            init(path: String) {
                self.path = path
            }
            
            func resultString(at stage: Stage) -> String {
                switch stage {
                case .parse, .macro:
                    return template!.print()
                case .compile:
                    return code!
                case .render:
                    return rendered!
                }
            }
        }
        
        var writeOnSame: Bool = false
        var entries: [Entry] = []
    }
    
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
    
    init(state: State) {
        self.state = state
    }
    
    func run(to stage: Stage) throws {
        if state.writeOnSame {
            guard stage == .render else {
                throw Error(message: "`--write` requires `--render` mode")
            }
            
            for i in 0..<state.entries.count {
                let path = URL.init(fileURLWithPath: state.entries[i].path)
                if state.entries[i].destPath == nil {
                    guard path.pathExtension == "gysb" else {
                        throw Error(message: "source path has not `.gysb`, so dest path decision failed: path=\(state.entries[i].path)")
                    }
                    state.entries[i].destPath = path.deletingPathExtension().path
                }
            }
            
            try process(to: stage)

            for i in 0..<state.entries.count {
                let dest = state.entries[i].destPath!
                let ret = state.entries[i].rendered!
                print("write: \(dest)")
                try ret.write(toFile: dest, atomically: true, encoding: .utf8)
            }
        } else {
            let ret = try render(to: stage)
            print(ret, terminator: "")
        }
    }
    
    func render(to stage: Stage) throws -> String {
        guard state.entries.count == 1 else {
            throw Error(message: "entry count must be 1 to render")
        }
        
        try process(to: stage)
        
        return state.entries[0].resultString(at: stage)
    }
    
    private func process(to stage: Stage) throws {
        for i in 0..<state.entries.count {
            let path = state.entries[i].path
            
            let source = try String(contentsOfFile: path, encoding: .utf8)
            
            state.entries[i].source = source
        }
        
        for i in 0..<state.entries.count {
            let source = state.entries[i].source!
            let template = try Parser.init(source: source).parse()
            state.entries[i].template = template
            state.entries[i].source = nil
        }
        
        if stage == .parse {
            return
        }
        
        for i in 0..<state.entries.count {
            let path = state.entries[i].path
            var template = state.entries[i].template!
            template = try MacroExecutor.init(template: template, path: path).execute()
            state.entries[i].template = template
        }
        if stage == .macro {
            return
        }
        
        for i in 0..<state.entries.count {
            let template = state.entries[i].template!
            let code = CodeGenerator.init(template: template).generate()
            state.entries[i].code = code
            state.entries[i].template = nil
        }
        if stage == .compile {
            return
        }
        
        for i in 0..<state.entries.count {
            let path = state.entries[i].path
            let code = state.entries[i].code!
            let rendered = try CodeExecutor(code: code, path: path).execute()
            state.entries[i].rendered = rendered
            state.entries[i].code = nil
        }
    }
    
    private let state: State
}
