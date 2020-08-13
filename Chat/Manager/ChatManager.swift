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
    var tasks: [Task] = []

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

        NotificationCenter.default.addObserver(self, selector: #selector(sendTasks(_:)), name: NSNotification.Name(rawValue: "receiver is on"), object: nil)

        guard let isReceiverOn = SocketIOService.shared.contacts.first(where: { $0.nickname == receiver })?.isConnected else { return }

        if isReceiverOn {

            SocketIOService.shared.send(message: message, with: socket.sender.nickname, to: receiver)
        } else {

            newTask(from: socket.sender.nickname, to: receiver, message: message) { task in

                guard let task = task else { return }

                self.tasks.append(task)
            }
        }
    }

    @objc func sendTasks(_ notification: NSNotification) {

        if let dict = notification.userInfo as NSDictionary? {

            if let nickname = dict["nickname"] as? String {

                tasks.forEach { task in

                    if task.receiver == nickname {

                        socket.send(message: task.message, with: task.sender, to: task.receiver)
                    }
                }
            }
        }
    }

    func newTask(from sender: String, to receiver: String, message: String, _ completion: @escaping ((Task?) -> Void)) {

        let connection = RMQConnection(uri: "amqp://guest:guest@localhost:5672", delegate: RMQConnectionDelegateLogger())
        connection.start()
        
        let channel = connection.createChannel()
        let queue = channel.queue(receiver, options: .durable)

        let task = Task(sender: sender, receiver: receiver, message: message)

        if let messageData = try? JSONEncoder().encode(task) {
            
            receiveTask(receiver) { task in
                completion(task)
            }
            
            queue.publish(messageData, persistent: true)

            print("\(sender) sent \(message) to \(receiver)")
        }
    }

    func receiveTask(_ receiver: String, _ completion: @escaping ((Task?) -> Void)) {

        let connection = RMQConnection(uri: "amqp://guest:guest@localhost:5672", delegate: RMQConnectionDelegateLogger())
        connection.start()

        let channel = connection.createChannel()
        let queue = channel.queue(receiver, options: .durable)

        channel.basicQos(1, global: false)

        queue.subscribe({(_ rmqMessage: RMQMessage) -> Void in

            let message = try? JSONDecoder().decode(Task.self, from: rmqMessage.body)

            completion(message)
        })
    }
    
}

struct Task: Codable {
    var sender: String
    var receiver: String
    var message: String
}
