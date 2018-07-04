//
//  DistanceTableViewCell.swift
//  MapApp
//
//  Created by Thanh Quach on 7/4/18.
//  Copyright © 2018 Sea Group Limited. All rights reserved.
//

import UIKit

class DistanceTableViewCell: UITableViewCell {

    enum `Type` {
        case normal
        case selected
        case header
    }

    @IBOutlet weak var distanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.distanceLabel.clipsToBounds = true
        self.distanceLabel.layer.cornerRadius = 2
    }

    func bindingUI(text: String, type: Type) {

        self.distanceLabel.text = text

        switch type {
        case .normal:
            self.distanceLabel.backgroundColor = .white
        case .selected:
            self.distanceLabel.backgroundColor = .lightGray
        case .header:
            self.distanceLabel.backgroundColor = .clear
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.distanceLabel.text = nil
        self.distanceLabel.backgroundColor = .white
    }

}
