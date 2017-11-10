//
//  PackageDependency.swift
//  GysbSwiftConfig
//
//  Created by omochimetaru on 2017/11/10.
//

import Foundation
import GysbBase

public extension Config.PackageDependency.Requirement {
    public init(from decoder: Decoder) throws {
        let kc = try decoder.container(keyedBy: CodingKeys.self)
        let type = try kc.decode(String.self, forKey: .type)
        switch type {
        case "exact":
            let id = try kc.decode(String.self, forKey: .identifier)
            self = .exact(id)
        case "revision":
            let id = try kc.decode(String.self, forKey: .identifier)
            self = .revision(id)
        default:
            throw Error(message: "invalid type: \(type)")
        }
    }
}
