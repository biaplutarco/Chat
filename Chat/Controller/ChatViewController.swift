//
//  ChatViewController.swift
//  Chat
//
//  Created by Bia Plutarco on 05/08/20.
//  Copyright © 2020 Bia Plutarco. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!

    var messages = [MessageInfo]() {
        didSet {
            tableView.reloadData()
        }
    }

    var contactName: String? {
        didSet {
            title = contactName
        }
    }

    var sender: Contact = SocketIOService.shared.sender

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "cell")

        getMessage()
    }

    func getMessage() {
        SocketIOService.shared.getChatMessage { (message) in
            DispatchQueue.main.async {
                self.messages.append(message)
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func didTapSend(_ sender: Any) {

        if !textField.text!.isEmpty, let message = textField.text {

            SocketIOService.shared.send(message: message, with: self.sender.nickname)

            textField.text = nil
            textField.resignFirstResponder()
        }
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ChatTableViewCell else { return UITableViewCell() }

        let content = messages[indexPath.row].content
        let sender = messages[indexPath.row].sender

        cell.setup(with: content, sender: sender)
        
        return cell
    }
}
