//
//  Error.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

struct Error : Swift.Error, CustomStringConvertible {
    init(message: String) {
        self.message = message
    }
    
    var message: String
    
    var description: String {
        return "Error(\(message))"
    }
}
