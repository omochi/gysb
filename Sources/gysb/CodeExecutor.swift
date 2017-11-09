import Foundation

class CodeExecutor {
    init(code: String,
         path: String)
    {
        self.code = code
        self.path = path
    }
    
    func execute() throws -> String {
        let dir = NSTemporaryDirectory()
        let file = getBaseName() + "_" + randomSuffix() + ".swift"
        
        let path = URL(fileURLWithPath: dir).appendingPathComponent(file).path
        
        try code.write(toFile: path, atomically: true, encoding: .utf8)
        let result = try runSwift(path: path)
        try? FileManager.default.removeItem(atPath: path)
        return result
    }
    
    func runSwift(path: String) throws -> String {
        let swiftPath = try execWhich(name: "swift")
        return try execCapture(path: swiftPath, arguments: [path])
    }
    
    private func getBaseName() -> String {
        var name = URL(fileURLWithPath: path)
        name = URL(fileURLWithPath: name.lastPathComponent)
        while true {
            if name.pathExtension.isEmpty {
                break
            }
            name = name.deletingPathExtension()
        }
        return name.relativePath
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
    
    private let code: String
    private let path: String
}
