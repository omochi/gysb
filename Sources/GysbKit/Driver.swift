//
//  Driver.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

import GysbBase

public class Driver {
    public class State {
       public  struct Entry {
            public var path: URL
            public var configPath: URL?
            
            public var destPath: URL?
            
            public var source: String?
            public var template: Template?

            
            public var code: String?
            
            public var rendered: String?
            
            public init(path: URL) {
                self.path = path
            }
        }
        
        public struct BuildWork {
            public var config: Config
            public var workDir: URL
            public var entryIndices: [Int]
        }
        
        public var writeOnSame: Bool = false
        public var logPrintEnabled: Bool = false
        
        public var entries: [Entry] = []
        public var buildWorks: [BuildWork] = []
        
        public let includeFilesTargetName: String = "gysb_include_files"
    }
    
    public enum Stage {
        case parse
        case macro
        case compile
        case render
        
        public init(appMode: App.Mode) {
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
    
    public init(state: State) {
        self.state = state
    }
    
    public convenience init(path: URL) {
        self.init(paths: [path], writeOnSame: false)
    }
    
    public convenience init(paths: [URL], writeOnSame: Bool) {
        let state = State.init()
        state.entries = paths.map {
            State.Entry.init(path: $0)
        }
        state.writeOnSame = writeOnSame
        self.init(state: state)
    }
    
    public func run(to stage: Stage) throws {
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
    
    public func render(to stage: Stage) throws -> String {
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
            let configPath = searchConfigJSON(sourcePath: path)
            
            state.entries[i].source = source
            state.entries[i].configPath = configPath
        }
        
        
        for i in 0..<state.entries.count {
            let source = state.entries[i].source!
            let path = state.entries[i].path
            let template = try Parser.init(source: source, path: path).parse()
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
        let fm = FileManager.default
        
        var configPathToIndices = [String: [Int]]()
        var noConfigIndices = [Int]()
        
        for i in 0..<state.entries.count {
            if let configPath = state.entries[i].configPath {
                let key = configPath.path
                
                var indices = configPathToIndices[key] ?? []
                indices.append(i)
                configPathToIndices[key] = indices
            } else {
                noConfigIndices.append(i)
            }
        }
        
        func createWorkDir(suffix: String) throws -> URL {
            let workDir = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent("gysb")
                .appendingPathComponent("swiftpm_" + suffix)
            try fm.createDirectory(at: workDir, withIntermediateDirectories: true)
            return workDir
        }
        
        for configPathStr in configPathToIndices.keys {
            let configPath = URL.init(fileURLWithPath: configPathStr)
            let config = try Config.fromJSON(path: configPath)
            
            // workspace is bound to swift config json filepath
            let workDirSuffix = getSha256(string: configPath.path).slice(start: 0, len: 16)
            
            let workDir = try createWorkDir(suffix: workDirSuffix)
            
            let entryIndices: [Int] = configPathToIndices[configPathStr]!
            
            let work = State.BuildWork(config: config,
                                       workDir: workDir,
                                       entryIndices: entryIndices)
            state.buildWorks.append(work)
        }
        
        if noConfigIndices.count > 0 {
            let config = Config.init()
            
            // workspace is bound to one source filepath
            
            let leaderPath = noConfigIndices.map { state.entries[$0] }.map { $0.path.path }.sorted().first!
            let workDirSuffix = getSha256(string: leaderPath).slice(start: 0, len: 16)
            let workDir = try createWorkDir(suffix: workDirSuffix)
            
            let work = State.BuildWork(config: config,
                                       workDir: workDir,
                                       entryIndices: noConfigIndices)
            state.buildWorks.append(work)
        }
        
        for i in 0..<state.entries.count {
            let codeGenerator = CodeGenerator(state: state, entryIndex: i)
            let code = codeGenerator.generate()
            state.entries[i].code = code
            state.entries[i].template = nil
        }
    }
    
    private func processRenderStage() throws {
        for iw in 0..<state.buildWorks.count {
            let work = state.buildWorks[iw]
            let executor = CodeExecutor.init(state: state, workIndex: iw, output: self.logPut)
            log("workdir: \(work.workDir.path)")
            try executor.deploy()
            
            for ie in work.entryIndices {
                let rendered = try executor.execute(entryIndex: ie)
                state.entries[ie].rendered = rendered
            }
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
    
    private func searchConfigJSON(sourcePath: URL) -> URL? {
        let fm = FileManager.default
        
        var dir = sourcePath.deletingLastPathComponent().absoluteURL
        
        while true {
            let checkPath = dir.appendingPathComponent("gysb.json")
            if fm.fileExists(atPath: checkPath.path) {
                return checkPath
            }
            if dir.pathComponents.count == 1 {
                return nil
            }
            dir.deleteLastPathComponent()
        }
    }

    private let state: State
}
