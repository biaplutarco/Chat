//
//  ChatTableViewCell.swift
//  Chat
//
//  Created by Bia Plutarco on 07/08/20.
//  Copyright © 2020 Bia Plutarco. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    var isSender = false
    
    lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        return label
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        return label
    }()
    
    lazy var colorView: UIView = {
           let view = UIView()
           view.backgroundColor = .systemOrange
           view.layer.cornerRadius = 20
           view.translatesAutoresizingMaskIntoConstraints = false
           addSubview(view)
           
           return view
       }()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }

    func setup(with message: String, sender: String) {

        if SocketIOService.shared.sender.nickname == sender {
            colorView.backgroundColor = .systemGray6
        }
        
        messageLabel.text = message
        
        backgroundColor = .clear
        
        addSubviewConstraints(to: sender)
        sendSubviewToBack(colorView)
    }
    
    private func addSubviewConstraints(to sender: String) {

        if SocketIOService.shared.sender.nickname == sender {

            NSLayoutConstraint.activate([

                colorView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
                colorView.bottomAnchor.constraint(equalTo: bottomAnchor),
                colorView.trailingAnchor.constraint(equalTo: trailingAnchor),
                colorView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
                
                messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                messageLabel.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
                messageLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12)
                
            ])
        } else {

            NSLayoutConstraint.activate([

                colorView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
                colorView.bottomAnchor.constraint(equalTo: bottomAnchor),
                colorView.leadingAnchor.constraint(equalTo: leadingAnchor),
                colorView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16),

                messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                messageLabel.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
                messageLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12)
                
            ])
        }
    }
}
