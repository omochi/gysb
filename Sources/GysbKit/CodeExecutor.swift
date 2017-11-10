import Foundation
import GysbBase
import GysbSwiftConfig

class CodeExecutor {
    init(state: Driver.State,
         output: @escaping (String) -> Void)
    {
        self.state = state
        self.output = output
    }
    
    func deploy() throws {
        let fm = FileManager.default
        
        self.spmDir = state.workDir!.appendingPathComponent("swiftpm")
        try fm.createDirectory(at: spmDir, withIntermediateDirectories: true)
        
        for i in 0..<state.entries.count {
            let targetName = "render\(i)"
            state.entries[i].targetName = targetName
        }
        
        let generator = ManifestoGenerator(config: state.swiftConfig!,
                                           targetNames: state.entries.map { $0.targetName! })
        let manifesto = generator.generate()
        try manifesto.write(to: spmDir.appendingPathComponent("Package.swift"), atomically: true, encoding: .utf8)
        
        for i in 0..<state.entries.count {
            let targetName = state.entries[i].targetName!
            let code = state.entries[i].code!
            
            let targetDir = spmDir.appendingPathComponent("Sources").appendingPathComponent(targetName)
            try fm.createDirectory(at: targetDir, withIntermediateDirectories: true)
            
            try code.write(to: targetDir.appendingPathComponent("main.swift"), atomically: true, encoding: .utf8)
        }

        output("swift build\n")
        
        let swiftPath = try getSwiftPath()
        let args = ["build",
                    "--package-path", spmDir.path]
        
        try execPrintOrCapture(path: swiftPath, arguments: args,
                               print: state.logPrintEnabled ? output : nil)
    }
    
    func execute(index: Int) throws -> String {
        let dir = self.state.entries[index].path.deletingLastPathComponent()
        let cdBack = changeCurrentDirectory(path: dir)
        defer { cdBack() }
        
        let targetName = self.state.entries[index].targetName!
        let swiftPath = try getSwiftPath()
        let args = ["run",
                    "--package-path", spmDir.path,
                    targetName]
        return try execCapture(path: swiftPath,
                               arguments: args)
    }
    
    var spmDir: URL!
    
    private let state: Driver.State
    private let output: (String) -> Void
}
