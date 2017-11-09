import Foundation
import GysbBase

class CodeExecutor {
    init(state: Driver.State)
    {
        self.state = state
    }
    
    func deploy() throws {
        let dir: URL = URL.init(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("gysb_" + getRandomString(length: 8))
        
        try FileManager.default.createDirectory(atPath: dir.path, withIntermediateDirectories: false)
        state.executeDir = dir
        
        let path: URL = dir.appendingPathComponent("gysb.swift")
    
        try state.code!.write(toFile: path.path, atomically: true, encoding: .utf8)
        
        swiftcPath = URL.init(fileURLWithPath: try execWhich(name: "swiftc"))

        try execCapture(path: swiftcPath, arguments:
            ["-o",
             dir.appendingPathComponent("gysb_exe").path,
             path.path])
    }
    
    func execute(id: String) throws -> String {
        return try execCapture(path: state.executeDir!.appendingPathComponent("gysb_exe"),
                               arguments: [id])
    }
    
    func clear() {
        try? FileManager.default.removeItem(at: state.executeDir!)
    }
    
    private let state: Driver.State
    private var swiftcPath: URL!
}
