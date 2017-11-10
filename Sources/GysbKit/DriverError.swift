//
//  DriverError.swift
//  GysbKit
//
//  Created by omochimetaru on 2017/11/11.
//

import Foundation

public enum DriverError : Swift.Error, CustomStringConvertible {
    case invalidOption(String)
}

extension DriverError {
    public var description: String {
        switch self {
        case .invalidOption(let message):
            return "invalid option: \(message)"
        }
    }
}
