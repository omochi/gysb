//
//  DriverState.swift
//  GysbKit
//
//  Created by omochimetaru on 2017/11/10.
//

import Foundation

extension Driver.State {
    func resultString(index: Int, stage: Driver.Stage) -> String {
        switch stage {
        case .parse, .macro:
            return entries[index].template!.print()
        case .compile:
            return entries[index].code!
        case .render:
            return entries[index].rendered!
        }
    }
    
    func targetName(index: Int) -> String {
        return "render\(index)"
    }
}

extension Driver.State.BuildWork {
//    var 
}

