//
//  MessageInfo.swift
//  Chat
//
//  Created by Bia Plutarco on 08/08/20.
//  Copyright © 2020 Bia Plutarco. All rights reserved.
//

import Foundation

struct MessageInfo: Codable {

    var sender: String
    var content: String
    var date: String
    var receiver: String
}

extension MessageInfo: Equatable, Hashable {
    static func ==(lhs: MessageInfo, rhs: MessageInfo) -> Bool {
        return lhs.sender == rhs.sender && lhs.content == rhs.content && lhs.date == rhs.date && lhs.receiver == rhs.receiver
    }
}
