//
//  ParserError.swift
//  GysbKit
//
//  Created by omochimetaru on 2017/11/11.
//

import Foundation

public struct ParserError : Swift.Error, CustomStringConvertible {
    public init(message: String,
                path: URL?,
                line: Int,
                column: Int)
    {
        self.message = message
        self.path = path
        self.line = line
        self.column = column
    }
    
    public var message: String
    public var path: URL?
    public var line: Int
    public var column: Int
    
    public var description: String {
        var posStrs = [String]()
        if let path = path {
            posStrs.append(path.relativePath)
        }
        posStrs.append("\(line)")
        posStrs.append("\(column)")
        return posStrs.joined(separator: ":") + ": " + message
    }
}
