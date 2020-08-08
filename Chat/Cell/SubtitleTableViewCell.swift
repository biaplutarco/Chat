//
//  SubtitleTableViewCell.swift
//  Chat
//
//  Created by Bia Plutarco on 08/08/20.
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
