import Foundation
import GysbBase

class CodeExecutor {
    init(state: Driver.State,
         workIndex: Int,
         output: @escaping (String) -> Void)
    {
        self.state = state
        self.workIndex = workIndex
        self.output = output
    }
    
    func deploy() throws {
        let fm = FileManager.default
        
        let buildWork = state.buildWorks[workIndex]
        
        self.spmDir = buildWork.workDir.appendingPathComponent("swiftpm")
        try fm.createDirectory(at: spmDir, withIntermediateDirectories: true)
        
        let targetNames = buildWork.entryIndices.map { state.targetName(index: $0) }
        let generator = SPMManifestoGenerator(config: buildWork.config,
                                              targetNames: targetNames)
        let manifesto = generator.generate()
        try manifesto.write(to: spmDir.appendingPathComponent("Package.swift"), atomically: true, encoding: .utf8)
        
        for i in buildWork.entryIndices {
            let targetName = state.targetName(index: i)
            let code = state.entries[i].code!
            
            let targetDir = spmDir.appendingPathComponent("Sources").appendingPathComponent(targetName)
            try fm.createDirectory(at: targetDir, withIntermediateDirectories: true)
            
            try code.write(to: targetDir.appendingPathComponent("main.swift"),
                           atomically: true, encoding: .utf8)
        }

        output("swift build\n")
        
        let swiftPath = try getSwiftPath()
        let args = ["build",
                    "--package-path", spmDir.path]
        
        try execPrintOrCapture(path: swiftPath, arguments: args,
                               print: state.logPrintEnabled ? output : nil)        
    }
    
    func execute(entryIndex: Int) throws -> String {
        let dir = state.entries[entryIndex].path.deletingLastPathComponent()
        let cdBack = changeCurrentDirectory(path: dir)
        defer { cdBack() }
        
        let targetName = state.targetName(index: entryIndex)
        let swiftPath = try getSwiftPath()
        let args = ["run",
                    "--package-path", spmDir.path,
                    targetName]
        return try execCapture(path: swiftPath,
                               arguments: args)
    }
    
    var spmDir: URL!
    
    private let state: Driver.State
    private let workIndex: Int
    private let output: (String) -> Void
}
