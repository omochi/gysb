import Foundation
import GysbBase
import GysbSwiftConfig

class CodeExecutor {
    init(state: Driver.State)
    {
        self.state = state
        
        targetName = "GysbRender"
    }
    
    func deploy() throws {
        let fm = FileManager.default
        
        self.spmDir = state.workDir!.appendingPathComponent("swiftpm")
        try fm.createDirectory(at: spmDir, withIntermediateDirectories: true)
        
        let generator = ManifestoGenerator(config: state.swiftConfig!, name: targetName)
        let manifesto = generator.generate()
        try manifesto.write(to: spmDir.appendingPathComponent("Package.swift"), atomically: true, encoding: .utf8)
        
        let targetDir = spmDir.appendingPathComponent("Sources").appendingPathComponent(targetName)
        try fm.createDirectory(at: targetDir, withIntermediateDirectories: true)
        
        try state.code!.write(to: targetDir.appendingPathComponent("main.swift"), atomically: true, encoding: .utf8)
        
        fm.changeCurrentDirectoryPath(spmDir.path)
        
        try execCapture(path: try getSwiftPath(),
                        arguments: ["build"])
    }
    
    func execute(id: String) throws -> String {
        return try execCapture(path: try getSwiftPath(),
                               arguments: ["run", targetName, id])
    }

    var targetName: String
    
    var spmDir: URL!

    private let state: Driver.State
}
