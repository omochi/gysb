//
//  Glob.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

public func glob(pattern: String, in directory: String?) -> [String] {
    let fm = FileManager.default
    
    let ocd = fm.currentDirectoryPath
    var ret = [String]()
    
    if let dir = directory {
        fm.changeCurrentDirectoryPath(dir)
    }
    
    var obj = glob_t.init()
    defer {
        globfree(&obj)
        fm.changeCurrentDirectoryPath(ocd)
    }
    
    Darwin.glob(pattern.cString(using: .utf8),
                GLOB_TILDE | GLOB_MARK | GLOB_BRACE,
                nil, &obj)
    for i in 0..<obj.gl_matchc {
        let path = String.init(cString: obj.gl_pathv[Int(i)]!)
        ret.append(URL.init(fileURLWithPath: path).path)
    }
    
    return ret
}
