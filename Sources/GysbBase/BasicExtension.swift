//
//  ArrayExtension.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/08.
//

import Foundation

extension String {
    public func getOrNone(_ index: String.Index) -> Character? {
        if index == endIndex {
            return nil
        }
        return self[index]
    }
    
    public func slice(start: Int, len: Int) -> String {
        let start = max(0, min(start, self.count))
        let end = max(0, min(start + len, self.count))
        let range = index(startIndex, offsetBy: start)..<index(startIndex, offsetBy: end)
        return String(self[range])
    }
}

extension Sequence {
    public func testAll(_ pred: (Element) -> Bool) -> Bool {
        for x in self {
            if !pred(x) {
                return false
            }
        }
        return true
    }
    
    public func testAny(_ pred: (Element) -> Bool) -> Bool {
        for x in self {
            if pred(x) {
                return true
            }
        }
        return false
    }
}

#if os(Linux)
extension ObjCBool {
    public var boolValue: Bool {
        return self == true
    }
}
#endif
