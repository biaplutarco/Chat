//
//  Contact.swift
//  Chat
//
//  Created by Bia Plutarco on 08/08/20.
//  Copyright © 2020 Bia Plutarco. All rights reserved.
//

import Foundation

struct ContactInfo {
        
    let identifier = UUID()
    let id: String
    let nickname: String
    let isConnected: Bool
        
    init(data: [String: AnyObject]) {
        self.id = data["id"] as! String
        self.nickname = data["nickname"] as! String
        self.isConnected = data["isConnected"] as! Bool
    }
}

struct Contact {
        
    let identifier = UUID()
    let id: String
    let nickname: String
    var isConnected: Bool
}

extension ContactInfo: Equatable, Hashable {
    static func ==(lhs: ContactInfo, rhs: ContactInfo) -> Bool {
        return lhs.nickname == rhs.nickname && lhs.isConnected == rhs.isConnected
    }
}
