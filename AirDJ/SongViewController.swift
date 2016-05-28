//
//  SongViewController.swift
//  AirDJ
//
//  Created by John Qian on 5/28/16.
//  Copyright © 2016 imect. All rights reserved.
//

import UIKit

class SongViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    
    var musicIsPlaying = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func playButtonTapped(sender: AnyObject) {
        if (musicIsPlaying) {
            musicIsPlaying = false
            playButton.setImage(UIImage(named: "Play"), forState: UIControlState.Normal)
        } else {
            musicIsPlaying = true
            playButton.setImage(UIImage(named: "Pause"), forState: UIControlState.Normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
