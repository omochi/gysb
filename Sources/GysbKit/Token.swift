//
//  Token.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

enum Token : CustomStringConvertible {
    case char(String)
    case newline(String) // \r\n, \n, \r
    case white(String) // " ", \t
    case codeOpen // %{
    case codeClose // }%
    case codeLine // %
    case macroLine // %!
    case substOpen // ${
    case leftBrace // {
    case rightBrace // }
    case end
    
    var description: String {
        switch self {
        case let .char(char):
            return char
        case let .newline(char):
            return char
        case let .white(char):
            return char
        case .codeOpen:
            return "%{"
        case .codeClose:
            return "}%"
        case .codeLine:
            return "%"
        case .macroLine:
            return "%!"
        case .substOpen:
            return "${"
        case .leftBrace:
            return "{"
        case .rightBrace:
            return "}"
        case .end:
            return ""
        }
    }
}

