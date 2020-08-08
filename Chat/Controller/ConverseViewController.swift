//
//  ConverseViewController.swift
//  Chat
//
//  Created by Bia Plutarco on 05/08/20.
//  Copyright © 2020 Bia Plutarco. All rights reserved.
//

import UIKit

class ConverseViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var onOffButton: UIBarButtonItem!
    
    var contacts = [Contact]()
    var isOn = true

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "SubtitleTableViewCell")

        updateContatsStates()
        ChatManager.shared.saveMessages()
    }

    func updateContatsStates() {

        SocketIOService.shared.getExitUser { exitUserNickname in

            DispatchQueue.main.async {

                if let index = self.contacts.firstIndex(where: { $0.nickname == exitUserNickname }) {
                    self.contacts[index].isConnected = false

                    self.tableView.reloadData()
                }
            }
        }

        SocketIOService.shared.getConnectUser { connectedUser in

            DispatchQueue.main.async {

                if let index = self.contacts.firstIndex(where: { $0.nickname == connectedUser }) {
                    self.contacts[index].isConnected = true

                    self.tableView.reloadData()
                }
            }
        }
    }

    @IBAction func add(_ sender: Any) {

        let storyBoard = UIStoryboard(name: "Main", bundle:nil)

        let controller = storyBoard.instantiateViewController(withIdentifier: "NewContactViewController") as! NewContactViewController
        controller.delegate = self

        present(controller, animated:true, completion:nil)
    }

    @IBAction func onOff(_ sender: Any) {

        if isOn {

            SocketIOService.shared.exit(contact: SocketIOService.shared.sender.nickname) {

                self.onOffButton.title = "Offline"
                self.onOffButton.tintColor = .systemRed

                self.isOn = false

                SocketIOService.shared.sender.isConnected = false
                self.tableView.reloadData()
            }
        } else {

            SocketIOService.shared.connectToServer(with: SocketIOService.shared.sender.nickname) { _ in

                self.onOffButton.title = "Online"
                self.onOffButton.tintColor = .systemGreen

                self.isOn = true

                SocketIOService.shared.sender.isConnected = true
                self.tableView.reloadData()
            }
        }

        updateContatsStates()
    }

    @IBAction func exit(_ sender: Any) {

        SocketIOService.shared.exit(contact: SocketIOService.shared.sender.nickname) {

            self.tableView.reloadData()

            SocketIOService.shared.contacts.removeAll()
        }
    }
}

extension ConverseViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleTableViewCell", for: indexPath)
        cell.textLabel?.text = contacts[indexPath.row].nickname

        if contacts[indexPath.row].isConnected {

            cell.detailTextLabel?.text = "Online"
            cell.detailTextLabel?.textColor = .systemGreen
        } else {

            cell.detailTextLabel?.text = "Offline"
            cell.detailTextLabel?.textColor = .systemRed
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let storyBoard = UIStoryboard(name: "Main", bundle:nil)

        let controller = storyBoard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        controller.contactName = contacts[indexPath.row].nickname

        navigationController?.pushViewController(controller, animated:true)
    }
}

extension ConverseViewController: NewContactViewControllerDelegate {

    func saveContact(withName name: String?) {

        if let name = name {

            SocketIOService.shared.contacts.forEach { contact in

                if contact.nickname == name && !self.contacts.contains(where: { $0.nickname == name }) {

                    self.contacts.append(Contact(id: contact.id, nickname: contact.nickname, isConnected: true))
                }
            }

            tableView.reloadData()
        }
    }
}
