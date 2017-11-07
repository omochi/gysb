//
//  Token.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/07.
//

enum Token : Equatable, CustomStringConvertible {
    case char(String)
    case newline(String) // \r\n, \n, \r
    case codeOpen // %{
    case codeClose // }%
    case codeLine // %
    case substOpen // ${
    case leftBrace // {
    case rightBrace // }
    
    var description: String {
        switch self {
        case let .char(char):
            return char
        case let .newline(char):
            return char
        case .codeOpen:
            return "%{"
        case .codeClose:
            return "}%"
        case .codeLine:
            return "%"
        case .substOpen:
            return "${"
        case .leftBrace:
            return "{"
        case .rightBrace:
            return "}"
        }
    }
}

func ==(_ a: Token, _ b: Token) -> Bool {
    switch (a, b) {
    case let (.char(x), .char(y)):
        return x == y
    case let (.newline(x), .newline(y)):
        return x == y
    case (.codeOpen, .codeOpen),
         (.codeClose, .codeClose),
         (.codeLine, .codeLine),
         (.substOpen, .substOpen),
         (.leftBrace, .leftBrace),
         (.rightBrace, .rightBrace):
        return true
    default:
        return false
    }
}
