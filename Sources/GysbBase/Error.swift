//
//  Error.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

public struct Error : Swift.Error, CustomStringConvertible {
    public init(message: String) {
        self.message = message
    }
    
    public var message: String
    
    public var description: String {
        return message
    }
}
