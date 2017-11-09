//
//  ArrayExtension.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/08.
//

extension String {
    func getOrNone(_ index: String.Index) -> Character? {
        if index == endIndex {
            return nil
        }
        return self[index]
    }
}

extension Sequence {
    func testAll(_ pred: (Element) -> Bool) -> Bool {
        for x in self {
            if !pred(x) {
                return false
            }
        }
        return true
    }
    
    func testAny(_ pred: (Element) -> Bool) -> Bool {
        for x in self {
            if pred(x) {
                return true
            }
        }
        return false
    }
}
