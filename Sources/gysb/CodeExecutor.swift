import Foundation

class CodeExecutor {
    func execute(code: String,
                 name: String) throws {
        let dir = NSTemporaryDirectory()
        let file = name + "_" + randomSuffix() + ".swift"
        let path = (dir as NSString).appendingPathComponent(file)
        try code.write(toFile: path, atomically: true, encoding: .utf8)
        try runSwift(path: path)
        try? FileManager.default.removeItem(atPath: path)
        
    }
    
    func runSwift(path: String) throws {
        let swiftPath = try getSwiftPath()
        
        let process = Process.launchedProcess(launchPath: swiftPath,
                                              arguments: [path])
        process.waitUntilExit()
        if process.terminationStatus != EXIT_SUCCESS {
            throw Error(message: "swift compile error")
        }
    }
    
    private func getSwiftPath() throws -> String {
        let stdoutPipe = Pipe()
        var stdoutData = Data()
        stdoutPipe.fileHandleForReading.readabilityHandler = { file in
            stdoutData.append(file.availableData)
        }
        
        let process = Process()
        process.launchPath = "/usr/bin/which"
        process.arguments = ["swift"]
        process.standardOutput = stdoutPipe
        process.launch()
        process.waitUntilExit()
        
        stdoutPipe.fileHandleForReading.readabilityHandler = nil
        
        if process.terminationStatus != EXIT_SUCCESS {
            throw Error(message: "swift command not found")
        }
        
        guard var path = String.init(data: stdoutData, encoding: .utf8) else {
            throw Error(message: "which command output decode failed")
        }
        
        path = path.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        return path
    }
    
    private func randomSuffix() -> String {
        let chars = [
            "abcdefghijklmnopqrstuvwxyz",
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
            "0123456789"].joined()
        
        var ret = ""
        for _ in 0..<8 {
            let dice = Int(arc4random_uniform(UInt32(chars.count)))
            let charIndex = chars.index(chars.startIndex, offsetBy: dice)
            ret.append(chars[charIndex])
        }
        return ret
    }
}
