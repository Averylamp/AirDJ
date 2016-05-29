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
    var playbackIndicator: NAKPlaybackIndicatorView? = nil
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if playbackIndicator == nil{
            playbackIndicator = NAKPlaybackIndicatorView(frame: CGRectMake(0,0, 60,60))
            playbackIndicator?.center = numberLabel.center
            playbackIndicator?.alpha = 0.0
            self.addSubview(playbackIndicator!)
        }
        if selected{
            self.layoutIfNeeded()
            UIView.animateWithDuration(1.0, animations: {
                self.layoutIfNeeded()
            })
            
            UIView.animateWithDuration(0.5, animations: { 
                self.numberLabel.alpha = 0.0
                self.playbackIndicator?.alpha = 1.0
            })
            self.playbackIndicator?.state = NAKPlaybackIndicatorViewState.Playing
//            self.backgroundColor = UIColor(red: 0.980, green: 0.875, blue: 0.557, alpha: 1.00)
        }else{
            self.layoutIfNeeded()
            UIView.animateWithDuration(1.0, animations: {
                self.layoutIfNeeded()
                self.numberLabel.alpha = 1.0
                self.playbackIndicator?.alpha = 0.0
            })
            
            self.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        }
        // Configure the view for the selected state
    }

}
