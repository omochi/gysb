//
//  Token.swift
//  GysbMacroLib
//
//  Created by omochimetaru on 2017/11/10.
//

enum Token : CustomStringConvertible {
    case char(String)
    case newline(String) // \r\n, \n, \r
    case white(String) // " ", \t
    case keyword(String)
    case leftParen // (
    case rightParen // )
    case comma // ,
    case stringLiteral(String) // "aaa"
    case end
    
    var description: String {
        switch self {
        case .char(let char):
            return char
        case .newline(let char):
            return char
        case .white(let char):
            return char
        case .keyword(let str):
            return str
        case .leftParen:
            return "("
        case .rightParen:
            return ")"
        case .comma:
            return ","
        case .stringLiteral(let str):
            return str
        case .end:
            return ""
        }
    }
}

