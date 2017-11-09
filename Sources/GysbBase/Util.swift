//
//  Util.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation
import CommonCrypto

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
    if (path.relativePath as NSString).isAbsolutePath {
        return path
    }
    
    return directory.appendingPathComponent(path.relativePath)
}

public func getRandomString(length: Int) -> String {
    let chars = [
        "abcdefghijklmnopqrstuvwxyz",
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        "0123456789"].joined()
    
    var ret = ""
    for _ in 0..<length {
        let dice = Int(arc4random_uniform(UInt32(chars.count)))
        let charIndex = chars.index(chars.startIndex, offsetBy: dice)
        ret.append(chars[charIndex])
    }
    return ret
}

public func getSha256(string: String) -> String {
    let bufLen: Int = Int(CC_SHA256_DIGEST_LENGTH)
    let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: bufLen)
    defer { buf.deallocate(capacity: bufLen) }
    
    let data = Array(string.utf8)
    CC_SHA256(data, CC_LONG(data.count), buf)

    var ret = ""
    for i in 0..<bufLen {
        let byte: UInt8 = buf[i]
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




