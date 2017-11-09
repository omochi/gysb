//
//  Util.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

func escapeToSwiftLiteral(text: String) -> String {
    var s = text
    s = s.replacingOccurrences(of: "\\", with: "\\\\")
    s = s.replacingOccurrences(of: "\"", with: "\\\"")
    s = s.replacingOccurrences(of: "\t", with: "\\t")
    s = s.replacingOccurrences(of: "\n", with: "\\n")
    s = s.replacingOccurrences(of: "\r", with: "\\r")
    return s
}

func assertNotThrow<R>(_ reason: String, _ f: () throws -> R) -> R {
    do {
        return try f()
    } catch let e {
        fatalError("assert failure(\(reason)): \(e)")
    }
}

func cast<T, U>(_ t: T, to: U.Type) throws -> U {
    guard let u = t as? U else {
        throw Error(message: "cast failed: type=\(type(of: t)), to=\(U.self)")
    }
    return u
}

func resolvePath(_ path: String, in directory: String) -> String {
    if (path as NSString).isAbsolutePath {
        return path
    }
    
    return URL.init(fileURLWithPath: directory).appendingPathComponent(path).relativePath
}
