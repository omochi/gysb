//
//  Util.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation
import Cryptor

public func escapeToSwiftLiteral(text: String) -> String {
    var s = text
    s = s.replacingOccurrences(of: "\\", with: "\\\\")
    s = s.replacingOccurrences(of: "\"", with: "\\\"")
    s = s.replacingOccurrences(of: "\t", with: "\\t")
    s = s.replacingOccurrences(of: "\n", with: "\\n")
    s = s.replacingOccurrences(of: "\r", with: "\\r")
    return s
}

public func assertNotThrow<R>(_ reason: String, _ f: () throws -> R) -> R {
    do {
        return try f()
    } catch let e {
        fatalError("assert failure(\(reason)): \(e)")
    }
}

public func cast<T, U>(_ t: T, to: U.Type) throws -> U {
    guard let u = t as? U else {
        throw Error(message: "cast failed: type=\(type(of: t)), to=\(U.self)")
    }
    return u
}

public func resolvePath(_ path: URL, in directory: URL) -> URL {
    if NSString(string: path.relativePath).isAbsolutePath {
        return path
    }
    
    return directory.appendingPathComponent(path.relativePath)
}

public func getRandomUInt32() -> UInt32 {
    var bytes: [UInt8] = try! Random.generate(byteCount: 4)
    let p = UnsafeMutableRawPointer(&bytes).bindMemory(to: UInt32.self, capacity: 1)
    return p.pointee
}

public func getRandomString(length: Int) -> String {
    let chars = [
        "abcdefghijklmnopqrstuvwxyz",
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        "0123456789"].joined()
    
    var ret = ""
    for _ in 0..<length {
        let dice = Int(getRandomUInt32() & UInt32(chars.count))
        let charIndex = chars.index(chars.startIndex, offsetBy: dice)
        ret.append(chars[charIndex])
    }
    return ret
}

public func getSha256(string: String) -> String {
    let digest = Digest.init(using: .sha256)
    let _ = digest.update(string: string)
    let data = digest.final()
    
    var ret = ""
    for i in 0..<data.count {
        let byte: UInt8 = data[i]
        ret.append(String.init(format: "%02x", byte))
    }
    return ret
}

public func getSwiftPath() throws -> URL {
    swiftPath = try swiftPath ?? execWhich(name: "swift")
    return swiftPath!
}
private var swiftPath: URL?

public func getSwiftcPath() throws -> URL {
    swiftcPath = try swiftcPath ?? execWhich(name: "swiftc")
    return swiftcPath!
}
private var swiftcPath: URL?

// TODO: need robust way
public func decodeString(data: Data, coding: String.Encoding) -> String {
    return String.init(data: data, encoding: coding)!
}

public func changeCurrentDirectory(path: URL) -> () -> Void {
    let fm = FileManager.default
    let ocd: String = fm.currentDirectoryPath
    fm.changeCurrentDirectoryPath(path.path)
    return {
        fm.changeCurrentDirectoryPath(ocd)
    }
}

extension FileManager {
    public func isDirectory(atPath path: String) -> Bool {
        var isDir: ObjCBool = false
        let path = URL.init(fileURLWithPath: path).path
        return fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue
    }
}

extension NSLock {
    public func scope<R>(_ f: () throws -> R) rethrows -> R {
        lock()
        defer { unlock() }
        return try f()
    }
}
