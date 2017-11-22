//
//  Driver.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

import GysbBase

public class Driver {
    public struct Option {
        public var stage: Stage = .render
        public var writeOnSame: Bool = false
        public var sourceDirs: Bool = false
        public var paths: [String] = []
        
        public init() {}
    }
    
    public struct Entry {
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
        
    public class State {
        public var option: Option
        public var logPrintEnabled: Bool = false
        
        public var entries: [Entry] = []
        public var buildWorks: [BuildWork] = []
        
        public let includeFilesTargetName: String = "gysb_include_files"
        
        public init(option: Option) {
            self.option = option
        }
    }
    
    public enum Stage {
        case parse
        case compile
        case render
    }
    
    public init(option: Option) {
        self.state = State(option: option)
    }
    
    public convenience init(path: URL) {
        self.init(paths: [path], writeOnSame: false)
    }
    
    public convenience init(paths: [URL], writeOnSame: Bool) {
        var opt = Option()
        opt.stage = .render
        opt.paths = paths.map { $0.path }
        opt.writeOnSame = writeOnSame

        self.init(option: opt)
    }
    
    public func run() throws {
        try drive()
        
        if state.printResult {
            let result = state.resultString(index: 0, stage: state.option.stage)
            print(result, terminator: "")
        }
    }
    
    public func render() throws -> String {
        try drive()
        return state.resultString(index: 0, stage: state.option.stage)
    }
    
    private func drive() throws {
        if state.option.sourceDirs {
            state.option.writeOnSame = true
            
            state.entries = []
            for sourceDirStr in state.option.paths {
                let sourceDir = URL.init(fileURLWithPath: sourceDirStr)
                let paths: [URL] = try glob(pattern: "**/*.gysb", in: sourceDir)
                    .map { sourceDir.appendingPathComponent($0.relativePath) }
                state.entries.append(contentsOf: paths.map { (path: URL) -> Entry in
                    return Entry.init(path: path)
                })
            }
        } else {
            state.entries = state.option.paths.map { (pathStr: String) -> Entry in
                let path = URL.init(fileURLWithPath: pathStr)
                return Entry.init(path: path)
            }
        }
        
        if state.option.writeOnSame {
            state.logPrintEnabled = true
            
            guard case .render = state.option.stage else {
                throw DriverError.invalidOption("`--write` requires `--render` mode")
            }
            
            for i in 0..<state.entries.count {
                let path = state.entries[i].path
                if state.entries[i].destPath == nil {
                    guard path.pathExtension == "gysb" else {
                        throw DriverError.invalidOption("source path has not `.gysb`, so dest path decision failed: path=\(path.path)")
                    }
                    state.entries[i].destPath = path.deletingPathExtension()
                }
            }
        } else {
            state.logPrintEnabled = false
            
            guard state.entries.count == 1 else {
                throw DriverError.invalidOption("you can not specify multiple sources to render. consider `--write` mode")
            }
        }

        try processParseStage()
        if state.option.stage == .parse {
            return
        }

        try processCompileStage()
        if state.option.stage == .compile {
            return
        }
        
        try processRenderStage()
        
        if state.option.writeOnSame {
            for i in 0..<state.entries.count {
                let dest = state.entries[i].destPath!
                let ret = state.entries[i].rendered!
                log("write: \(dest.path)")
                try ret.write(to: dest, atomically: true, encoding: .utf8)
            }
        }
    }
    
    
    private func processParseStage() throws {
        for i in 0..<state.entries.count {
            let path = state.entries[i].path
            
            let source = try String.init(contentsOf: path, encoding: .utf8)
            let configPath = Config.searchForSource(path: path)
            
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
            
            let work = BuildWork(config: config,
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
            
            let work = BuildWork(config: config,
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
            log("[\(iw + 1)/\(state.buildWorks.count)] workdir: \(work.workDir.path)")
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

    private let state: State
}
