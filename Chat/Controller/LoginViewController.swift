//
//  ViewController.swift
//  Chat
//
//  Created by Bia Plutarco on 05/08/20.
//  Copyright © 2020 Bia Plutarco. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    var nickname: String!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func login(_ sender: Any) {
        connectPlayer(with: textField.text ?? "Sem nome")
    }
    
    func connectPlayer(with nickname: String) {

        SocketIOService.shared.connectToServer(with: nickname) { (contacts) in

            DispatchQueue.main.async {

                guard let contacts = contacts else { return }

                contacts.forEach { contact in

                    if SocketIOService.shared.contacts.contains(where: { $0.nickname == contact.nickname }) {

                        if let index =  SocketIOService.shared.contacts.firstIndex(where: { $0.nickname == contact.nickname }) {

                            SocketIOService.shared.contacts[index].isConnected = contact.isConnected

                        }
                    } else {

                        SocketIOService.shared.contacts.append(contact)
                    }

                    if contact.nickname == nickname {

                        self.nickname = nickname

                        SocketIOService.shared.sender = Contact(id: contact.id, nickname: contact.nickname, isConnected: contact.isConnected)
                    }
                }
            }
        }
    }
}

