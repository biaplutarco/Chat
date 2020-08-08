//
//  SocketIOManager.swift
//  Chat
//
//  Created by Bia Plutarco on 05/08/20.
//  Copyright © 2020 Bia Plutarco. All rights reserved.
//

import UIKit
import SocketIO

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

struct MessageInfo {
    var sender: String
    var content: String
    var date: String
}

class SocketIOService: NSObject {

    static let shared = SocketIOService()

    private var manager: SocketManager
    private var socket: SocketIOClient

    var contacts: [ContactInfo] = []
    var sender: Contact!

    override init() {

        self.manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
        self.socket = manager.defaultSocket

        super.init()
    }

    func establishConnection() {
        socket.connect()
    }

    func closeConnection() {
        socket.disconnect()
    }

    //  Connect
    func connectToServer(with nickname: String, completion: @escaping ([ContactInfo]?) -> Void) {
        socket.emit("connectUser", nickname)
        socket.on("userList") { (data, _) in
            let players = (data[0] as? [[String: AnyObject]])?.map(ContactInfo.init)
            completion(players)
        }
    }

    //  Desconnect
    func exit(contact nickname: String, completion: @escaping () -> Void) {
        socket.emit("exitUser", nickname)
        completion()
    }

    //  Chat
    func send(message: String, with nickname: String) {
        socket.emit("chatMessage", nickname, message)
    }

    func getChatMessage(completion: @escaping (MessageInfo) -> Void) {
        socket.on("newChatMessage") { (data, _) -> Void in
            let message = MessageInfo(sender: data[0] as! String, content: data[1] as! String, date: data[2] as! String)
            completion(message)
        }
    }
}
