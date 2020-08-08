//
//  NewContactViewController.swift
//  Chat
//
//  Created by Bia Plutarco on 05/08/20.
//  Copyright © 2020 Bia Plutarco. All rights reserved.
//

import UIKit

protocol NewContactViewControllerDelegate: class {
    func saveContact(withName name: String?)
}

class NewContactViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!

    weak var delegate: NewContactViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func save(_ sender: Any) {

        delegate?.saveContact(withName: self.textField.text)

        dismiss(animated: true, completion: nil)
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
