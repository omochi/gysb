//
//  Glob.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

public func expandGlobStar(pattern: String, in directory: URL?) throws -> [String] {
    let fm = FileManager.default
    
    let cdBack = directory.map { changeCurrentDirectory(path: $0) }
    defer { cdBack?() }
    
    let patternParts: [String] = NSString(string: pattern).pathComponents
    let globStarNum = patternParts.filter { $0 == "**" }.count
    if globStarNum >= 2 {
        throw Error(message: "globstar can be used at most one")
    }
    
    guard let globStarIndex = (patternParts.index { $0 == "**" }) else {
        return [pattern]
    }
    
    var leadPath = ""
    for i in 0..<globStarIndex {
        leadPath = NSString(string: leadPath).appendingPathComponentCompat(patternParts[i])
    }
    
    func appendTailPath(to path: String) -> String {
        var path = path
        for i in (globStarIndex + 1)..<patternParts.count {
            path = NSString(string: path).appendingPathComponentCompat(patternParts[i])
        }
        return path
    }
    
    var ret: [String] = [
        appendTailPath(to: leadPath)
    ]
    
    let substSubpathStrs: [String]
    if fm.isDirectory(atPath: leadPath) {
        let path = URL.init(fileURLWithPath: leadPath).relativePath
        substSubpathStrs = try fm.subpathsOfDirectory(atPath: path)
        dump(substSubpathStrs)
    } else {
        substSubpathStrs = []
    }
    
    let expandedPaths: [String] = substSubpathStrs
        .map { NSString(string: leadPath).appendingPathComponentCompat($0) }
        .filter { fm.isDirectory(atPath: $0) }
    
    for expandedPath in expandedPaths {
        ret.append(appendTailPath(to: expandedPath))
    }
    
    return ret
}

public func glob(pattern: String, in directory: URL?) throws -> [URL] {
    let fm = FileManager.default
    
    let cdBack = directory.map { changeCurrentDirectory(path: $0) }
    defer { cdBack?() }
    
    var retStrs = [String]()
    
    var obj = glob_t.init()
    defer {
        globfree(&obj)
    }
    
    var patterns: [String] = [pattern]
    
    let patternParts: [String] = NSString(string: pattern).pathComponents
    if (patternParts.contains { $0 == "**" }) {
        patterns = try expandGlobStar(pattern: pattern, in: directory)
    }
    
    for ptn in patterns {
        glob(ptn.cString(using: .utf8),
             GLOB_TILDE | GLOB_MARK | GLOB_BRACE,
             nil, &obj)
        
        #if os(Linux)
            let n = Int(obj.gl_pathc)
        #else
            let n = Int(obj.gl_matchc)
        #endif
        
        for i in 0..<n {
            retStrs.append(String.init(cString: obj.gl_pathv[i]!))
        }
    }
    
    return retStrs.map { URL.init(fileURLWithPath: $0) }
}
