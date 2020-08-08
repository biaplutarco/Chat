//
//  ChatManager.swift
//  Chat
//
//  Created by Bia Plutarco on 08/08/20.
//  Copyright © 2020 Bia Plutarco. All rights reserved.
//

import Foundation
import SocketIO

class ChatManager {

    static let shared = ChatManager()

    var socket = SocketIOService.shared

    var chats: [Chat] = []

    private init() { }

    func saveMessages() {

        SocketIOService.shared.getChatMessage { (message) in

            let key = message.sender + message.receiver
            let inverseKey = message.receiver + message.sender

            if self.chats.contains(where: { $0.keys.contains(key) || $0.keys.contains(inverseKey) }) {

                if let index = self.chats.firstIndex(where: { $0.keys.contains(key) || $0.keys.contains(inverseKey) }) {

                    self.chats[index].messages.append(message)

                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Revieve message"), object: nil)
                }
            } else {

                let chat = Chat(keys: [key, inverseKey], messages: [message])

                self.chats.append(chat)

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Revieve message"), object: nil)
            }
        }
    }

    func getMessagesBetween(sender: String, receiver: String) -> [MessageInfo]? {

        let key = sender + receiver
        let inverseKey = receiver + sender

        if self.chats.contains(where: { $0.keys.contains(key) || $0.keys.contains(inverseKey) }) {

            if let index = chats.firstIndex(where: { $0.keys.contains(key) || $0.keys.contains(inverseKey) }) {

                return chats[index].messages
            } else {

                return nil
            }
        } else {

            return nil
        }
    }

    func send(to receiver: String, message: String) {
        SocketIOService.shared.send(message: message, with: socket.sender.nickname, to: receiver)
    }
}
