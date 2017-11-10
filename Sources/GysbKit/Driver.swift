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
            
            // macro result
            var swiftConfig: URL?
            
            var code: String?
            
            var targetName: String?
            var rendered: String?
            
            init(path: URL) {
                self.path = path
            }
        }
        
        var writeOnSame: Bool = false
        var logPrintEnabled: Bool = false
        
        var entries: [Entry] = []
        var workDir: URL?
        
        // using value
        var swiftConfig: Config?

        func resultString(index: Int, stage: Stage) -> String {
            switch stage {
            case .parse, .macro:
                return entries[index].template!.print()
            case .compile:
                return entries[index].code!
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
    
    convenience init(path: URL) {
        self.init(paths: [path], writeOnSame: false)
    }
    
    convenience init(paths: [URL], writeOnSame: Bool) {
        let state = State.init()
        state.entries = paths.map {
            State.Entry.init(path: $0)
        }
        state.writeOnSame = writeOnSame
        self.init(state: state)
    }
    
    func run(to stage: Stage) throws {
        if state.writeOnSame {
            guard stage == .render else {
                throw Error(message: "`--write` requires `--render` mode")
            }
            state.logPrintEnabled = true
            
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
                log("write: \(dest.path)")
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
        try processParseStage()
        if stage == .parse {
            return
        }
        
        try processMacroStage()
        if stage == .macro {
            return
        }
        
        try processCompileStage()
        if stage == .compile {
            return
        }
        
        try processRenderStage()
    }
    
    private func processParseStage() throws {
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
    }
    
    private func processMacroStage() throws {
        for i in 0..<state.entries.count {
            try MacroProcessor.init(state: state, index: i).execute()
        }

    }
    
    private func processCompileStage() throws {
        let workDirName: String
        
        let swiftConfigs = state.entries.flatMap { $0.swiftConfig }
        if swiftConfigs.count >= 2 {
            throw Error(message: "swiftpm definition must be in only one source")
        }
        
        if let configPath = swiftConfigs.first {
            // workspace is bound to swift config json filepath
            
            let data = try Data.init(contentsOf: configPath)
            state.swiftConfig = try JSONDecoder().decode(GysbSwiftConfig.Config.self, from: data)
            
            let str = getSha256(string: configPath.path).slice(start: 0, len: 16)
            workDirName = "gysb_" + str
        } else {
            state.swiftConfig = GysbSwiftConfig.Config()
            
            // workspace is bound to one source filepath
            
            let leaderPath = state.entries.map { $0.path.path }.sorted().first!
            let str = getSha256(string: leaderPath).slice(start: 0, len: 16)
            workDirName = "gysb_" + str
        }
        
        let workDir = URL.init(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(workDirName)
        try FileManager.default.createDirectory(at: workDir, withIntermediateDirectories: true)
        state.workDir = workDir
        log("workDir: \(workDir.path)")
        
        for i in 0..<state.entries.count {
            let codeGenerator = CodeGenerator(state: state, index: i)
            let code = codeGenerator.generate()
            state.entries[i].code = code
        }
    }
    
    private func processRenderStage() throws {
        let codeExecutor = CodeExecutor.init(state: state, output: self.logPut)
        try codeExecutor.deploy()
        
        for i in 0..<state.entries.count {
            let rendered = try codeExecutor.execute(index: i)
            state.entries[i].rendered = rendered
        }
    }
    
    private func log(_ s: String) {
        logPut(s + "\n")
    }
    
    private func logPut(_ s: String) {
        if state.logPrintEnabled {
            print(s, terminator: "")
        }
    }

    private let state: State
}
