//
//  Driver.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

import GysbBase
import GysbSwiftConfig

class Driver {
    class State {
        struct Entry {
            var path: URL
            var destPath: URL?
            
            var source: String?
            var template: Template?
            var swiftConfig: URL?
            var codeID: String?
            var rendered: String?
            
            init(path: URL) {
                self.path = path
            }
        }
        
        var writeOnSame: Bool = false
        var entries: [Entry] = []
        var code: String?
        var workDir: URL?
        var swiftConfig: Config?

        func resultString(index: Int, stage: Stage) -> String {
            switch stage {
            case .parse, .macro:
                return entries[index].template!.print()
            case .compile:
                return code!
            case .render:
                return entries[index].rendered!
            }
        }
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
    
    convenience init(path: String) {
        let state = State.init()
        state.entries = [
            State.Entry.init(path: URL.init(fileURLWithPath: path))
        ]
        self.init(state: state)
    }
    
    func run(to stage: Stage) throws {
        if state.writeOnSame {
            guard stage == .render else {
                throw Error(message: "`--write` requires `--render` mode")
            }
            
            for i in 0..<state.entries.count {
                let path = state.entries[i].path
                if state.entries[i].destPath == nil {
                    guard path.pathExtension == "gysb" else {
                        throw Error(message: "source path has not `.gysb`, so dest path decision failed: path=\(state.entries[i].path)")
                    }
                    state.entries[i].destPath = path.deletingPathExtension()
                }
            }
            
            try process(to: stage)

            for i in 0..<state.entries.count {
                let dest = state.entries[i].destPath!
                let ret = state.entries[i].rendered!
                print("write: \(dest.path)")
                try ret.write(to: dest, atomically: true, encoding: .utf8)
            }
        } else {
            let ret = try render(to: stage)
            print(ret, terminator: "")
        }
    }
    
    func render(to stage: Stage) throws -> String {
        switch stage {
        case .parse, .macro, .render:
            guard state.entries.count == 1 else {
                throw Error(message: "entry count must be 1 to render")
            }
        case .compile:
            break
        }
        
        try process(to: stage)
        
        return state.resultString(index: 0, stage: stage)
    }
    
    private func process(to stage: Stage) throws {
        for i in 0..<state.entries.count {
            let path = state.entries[i].path
            
            let source = try String.init(contentsOf: path, encoding: .utf8)
            
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
            try MacroProcessor.init(state: state, index: i).execute()
        }
        let swiftConfigs = state.entries.flatMap { $0.swiftConfig }
        if swiftConfigs.count >= 2 {
            throw Error(message: "swiftpm definition must be in only one source")
        }
        if stage == .macro {
            return
        }
        
        let workDirName: String
        
        if let configPath = swiftConfigs.first {
            let data = try Data.init(contentsOf: configPath)
            state.swiftConfig = try JSONDecoder().decode(GysbSwiftConfig.Config.self, from: data)

            let str = getSha256(string: configPath.path).slice(start: 0, len: 16)
            workDirName = "gysb_" + str
        } else {
            state.swiftConfig = GysbSwiftConfig.Config()
            
            let leaderPath = state.entries.map { $0.path.path }.sorted().first!
            let str = getSha256(string: leaderPath).slice(start: 0, len: 16)
            workDirName = "gysb_" + str
        }
        
        let workDir = URL.init(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(workDirName)
        try FileManager.default.createDirectory(at: workDir, withIntermediateDirectories: true)
        state.workDir = workDir
        
        for i in 0..<state.entries.count {
            state.entries[i].codeID = "id\(i)"
        }
        
        let codeGenerator = CodeGenerator(state: state)
        let code = codeGenerator.generate()
        state.code = code
        
        if stage == .compile {
            return
        }
        
        let codeExecutor = CodeExecutor.init(state: state)
        try codeExecutor.deploy()
        
        for i in 0..<state.entries.count {
            let rendered = try codeExecutor.execute(id: state.entries[i].codeID!)
            state.entries[i].rendered = rendered
        }
    }
    

    private let state: State
}
