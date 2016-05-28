//
//  SongTableViewCell.swift
//  AirDJ
//
//  Created by Avery Lamp on 5/28/16.
//  Copyright © 2016 imect. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected{
            self.layoutIfNeeded()
            UIView.animateWithDuration(1.0, animations: {
                self.layoutIfNeeded()
            })
//            self.backgroundColor = UIColor(red: 0.980, green: 0.875, blue: 0.557, alpha: 1.00)
        }else{
            self.layoutIfNeeded()
            UIView.animateWithDuration(1.0, animations: {
                self.layoutIfNeeded()
            })
            self.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        }
        // Configure the view for the selected state
    }

}
