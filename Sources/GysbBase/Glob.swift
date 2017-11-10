//
//  Glob.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

public func glob(pattern: String, in directory: URL?) -> [URL] {
    let cdBack = directory.map { changeCurrentDirectory(path: $0) }
    defer { cdBack?() }
    
    var ret = [URL]()
    
    var obj = glob_t.init()
    defer {
        globfree(&obj)
    }
    
    Darwin.glob(pattern.cString(using: .utf8),
                GLOB_TILDE | GLOB_MARK | GLOB_BRACE,
                nil, &obj)
    for i in 0..<obj.gl_matchc {
        let pathStr = String.init(cString: obj.gl_pathv[Int(i)]!)
        let path = URL.init(fileURLWithPath: pathStr)
        ret.append(path)
    }
    
    return ret
}
