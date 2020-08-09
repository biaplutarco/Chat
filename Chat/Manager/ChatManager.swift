//
//  ChatManager.swift
//  Chat
//
//  Created by Bia Plutarco on 08/08/20.
//  Copyright © 2020 Bia Plutarco. All rights reserved.
//

import Foundation
import SocketIO
import RMQClient

class ChatManager {

    static let shared = ChatManager()

    var socket = SocketIOService.shared

    var chats: [Chat] = []

    private init() { }

    func saveTasks() {

        receiveTask(socket.sender.nickname) { task in

            guard let task = task else { return }

            let message = MessageInfo(sender: task.sender, content: task.message, date: "", receiver: task.receiver)

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

        guard let isReceiverOn = SocketIOService.shared.contacts.first(where: { $0.nickname == receiver })?.isConnected else { return }

        if isReceiverOn {

            SocketIOService.shared.send(message: message, with: socket.sender.nickname, to: receiver)
        } else {

            newTask(from: socket.sender.nickname,to: receiver, message: message)
            saveTasks()
        }
    }

    func newTask(from sender: String, to receiver: String, message: String) {

        let connection = RMQConnection(uri: "amqp://test:test@localhost:5672/", delegate: RMQConnectionDelegateLogger())
        connection.start()
        
        let channel = connection.createChannel()
        let queue = channel.queue(receiver, options: .durable)

        let messageInfo = MessageInfo(sender: sender, content: message, date: "", receiver: receiver)

        if let messageData = try? JSONEncoder().encode(messageInfo) {
            
            channel.defaultExchange().publish(receiver.data(using: .utf8)!, routingKey: queue.name, persistent: true)

            print("Sent \(message)")

            connection.close()
        }
    }

    func receiveTask(_ receiver: String, _ completion: @escaping ((Task?) -> Void)) {

        let connection = RMQConnection(uri: "amqp://test:test@localhost:5672/", delegate: RMQConnectionDelegateLogger())
        connection.start()

        let channel = connection.createChannel()
        let queue = channel.queue(receiver, options: .durable)

        channel.basicQos(1, global: false)

        print("\(receiver): Waiting for messages")

        queue.subscribe({(_ rmqMessage: RMQMessage) -> Void in

//            let message = try? JSONDecoder().decode(Task.self, from: rmqMessage.body)
            let message = String(data: rmqMessage.body, encoding: .utf8)

            print("\(receiver): Received \(rmqMessage)")

            completion(Task(sender: "", receiver: receiver, message: message ?? ""))
        })
    }
    
}

struct Task: Codable {
    var sender: String
    var receiver: String
    var message: String
}
