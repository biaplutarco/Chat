//
//  ConverseViewController.swift
//  Chat
//
//  Created by Bia Plutarco on 05/08/20.
//  Copyright © 2020 Bia Plutarco. All rights reserved.
//

import UIKit

class SubtitleTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ConverseViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var onOffButton: UIBarButtonItem!
    
    var contacts = [ContactInfo]()
    var isOn = true

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "SubtitleTableViewCell")
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
            }
        } else {

            SocketIOService.shared.connectToServer(with: SocketIOService.shared.sender.nickname) { _ in

                self.onOffButton.title = "Online"
                self.onOffButton.tintColor = .systemGreen

                self.isOn = true

                SocketIOService.shared.sender.isConnected = true
            }
        }
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
        } else {

            cell.detailTextLabel?.text = "Offline"
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

                    self.contacts.append(contact)
                }
            }

            tableView.reloadData()
        }
    }
}
