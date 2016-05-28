//
//  ViewController.swift
//  AirDJ
//
//  Created by Avery Lamp on 5/28/16.
//  Copyright © 2016 imect. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var addSongButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSongButton.layer.cornerRadius = addSongButton.frame.height / 2
        addSongButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.6).CGColor
        addSongButton.layer.borderWidth = 1.0
        addSongButton.layer.masksToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = nil
        tableView.separatorStyle = .None
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func settingsClicked(sender: AnyObject) {
//        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//        self.navigationController?.pushViewController(storyboard.instantiateViewControllerWithIdentifier("SettingsVC"), animated: true)
        
        let controller = TLMSettingsViewController.settingsInNavigationController()
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: - TableView Data Source/ Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("songCell") as! SongTableViewCell
        
        cell.backgroundColor = nil
        if indexPath.row % 2 == 0{
            cell.backgroundColor = UIColor.whiteColor()
        }else{
            cell.backgroundColor = UIColor(red: 0.941, green: 0.945, blue: 0.961, alpha: 1.00)
        }
        cell.numberLabel.text = "\(indexPath.row + 1)"
        
//        let numberLabel = UILabel(frame: CGRectMake(0,0, cell.frame.height, cell.frame.height))
//         numberLabel.textAlignment = .Center
//        numberLabel.text = "\(indexPath.row + 1)"
//        numberLabel.textColor = UIColor(red: 0.173, green: 0.804, blue: 0.820, alpha: 1.00)
//        numberLabel.font = UIFont(name: "Panton-Regular", size: 24)
//        numberLabel.sizeToFit()
//        numberLabel.center = CGPointMake(cell.frame.height / 2 + 10, 40)
//        print(cell.frame)
//        cell.addSubview(numberLabel)
//        let labelOffset = numberLabel.frame.width + numberLabel.frame.origin.x + 30
//        let songTitleLabel = UILabel(frame: CGRectMake(labelOffset,10,cell.frame.width - labelOffset, 35 ))
//        songTitleLabel.text = "Dreams"
//        songTitleLabel.font = UIFont(name: "Panton-Regular", size: 20)
//        songTitleLabel.textColor = UIColor(white: 0.2, alpha: 1.0)
//        cell.addSubview(songTitleLabel)
//        
//        let songArtistLabel = UILabel(frame: CGRectMake(labelOffset, 35, cell.frame.width - labelOffset, 35))
//        songArtistLabel.text = "Katty Perry"
//        songArtistLabel.font = UIFont(name: "Panton-Light", size: 16)
//        songArtistLabel.textColor = UIColor(white: 0.3, alpha: 0.7)
//        cell.addSubview(songArtistLabel)
////        cell.selectionStyle = .None
//        let backgroundSelected = UIView(frame: CGRectMake(0,0, cell.frame.width, 80))
//        backgroundSelected.backgroundColor = UIColor(red: 0.980, green: 0.867, blue: 0.553, alpha: 1.00)
//        cell.selectedBackgroundView = backgroundSelected
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Song", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        self.navigationController?.pushViewController(vc!, animated: true)
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
