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
    
    var superPoweredMusic: Superpowered? = nil
    
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if selectedIndex != nil {
            let cell = tableView.cellForRowAtIndexPath(selectedIndex!) as! SongTableViewCell
            if cell.selected == true && superPoweredMusic!.isPlaying(){
                cell.playbackIndicator?.state = .Playing
            }else{
                cell.playbackIndicator?.state = .Paused
            }
        }
        
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
        
        cell.contentView.backgroundColor = nil
        if indexPath.row % 2 == 0{
            cell.contentView.backgroundColor = UIColor.whiteColor()
        }else{
            cell.contentView.backgroundColor = UIColor(red: 0.941, green: 0.945, blue: 0.961, alpha: 1.00)
        }
        cell.numberLabel.text = "\(indexPath.row + 1)"
        
        switch indexPath.row {
        case 0:
            cell.songTitleLabel.text = "Levels"
            cell.songArtistLabel.text = "Avicii"
        case 1:
            cell.songTitleLabel.text = "Airplanes, Part II"
            cell.songArtistLabel.text = "B.o.B feat Eminem"
        case 2:
            cell.songTitleLabel.text = "Sandstorm"
            cell.songArtistLabel.text = "Darude"
        case 3:
            cell.songTitleLabel.text = "Falling (Wheathin Remix)"
            cell.songArtistLabel.text = "Opia"
        case 4:
            cell.songTitleLabel.text = "Show Me Love (Big Wild Remix)"
            cell.songArtistLabel.text = "Hundred Waters"
        case 5:
            cell.songTitleLabel.text = "Mr. Watson (BKAYE Remix)"
            cell.songArtistLabel.text = "Cruel Youth"
        case 6:
            cell.songTitleLabel.text = "Dreams"
            cell.songArtistLabel.text = "Joakim Karud"
        case 7:
            cell.songTitleLabel.text = "Gekko"
            cell.songArtistLabel.text = "Oliver Heldens"
        case 8:
            cell.songTitleLabel.text = "You & Me"
            cell.songArtistLabel.text = "Flume"
        case 9:
            cell.songTitleLabel.text = "Some"
            cell.songArtistLabel.text = "Ahn Jung Jae & Sungha Jung"
        default:
            cell.songTitleLabel.text = "Gekko"
            cell.songArtistLabel.text = "Oliver Heldens"
        }
        let backgroundSelected = UIView(frame: CGRectMake(0,0, cell.frame.width, 80))
        backgroundSelected.backgroundColor = UIColor(red: 0.980, green: 0.867, blue: 0.553, alpha: 1.00)
        cell.selectedBackgroundView = backgroundSelected
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    var selectedIndex:NSIndexPath? = nil
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedIndex != nil {
            superPoweredMusic?.toggle()
            superPoweredMusic = nil
            print("Song already picked")
        }
        selectedIndex = indexPath
        if superPoweredMusic == nil {
            superPoweredMusic = Superpowered()
            switch indexPath.row {
            case 0:
                superPoweredMusic?.addSongWithName("01 Levels - Radio Edit", fileType: "mp3")
            case 1:
                superPoweredMusic?.addSongWithName("B.o.B - Airplanes, Part II [feat Eminem & Hayley Williams of Paramore] - Explicit Album Version", fileType: "mp3")
            case 2:
                superPoweredMusic?.addSongWithName("13 Sandstorm", fileType: "m4a")
            case 3:
                superPoweredMusic?.addSongWithName("Falling", fileType: "wav")
            case 4:
                superPoweredMusic?.addSongWithName("Hundred Waters - Show Me Love (Big Wild Remix)", fileType: "mp3")
            case 5:
                superPoweredMusic?.addSongWithName("Cruel Youth - Mr. Watson (BKAYE Remix)", fileType: "mp3")
            case 6:
                superPoweredMusic?.addSongWithName("Dreams", fileType: "mp3")
            case 7:
                superPoweredMusic?.addSongWithName("Oliver Heldens - Gecko _Original Mix_", fileType: "mp3")
            case 8:
                superPoweredMusic?.addSongWithName("Flume - You & Me - Flume Remix", fileType: "mp3")
            case 9:
                superPoweredMusic?.addSongWithName("-(Some) - Ahn Jung Jae & Sungha Jung", fileType: "mp3")
                
            default:
                superPoweredMusic?.addSongWithName("Oliver Heldens - Gecko _Original Mix_", fileType: "mp3")
            }
            
            
            
            superPoweredMusic?.toggle()
        }
        
        let storyboard = UIStoryboard(name: "Song", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as!SongViewController
        let cell = tableView.cellForRowAtIndexPath(indexPath) as? SongTableViewCell
        vc.view.frame = vc.view.frame
        vc.songTitleLabel.text = cell?.songTitleLabel.text
        vc.artistNameLabel.text = cell?.songArtistLabel.text
        vc.superPowered = self.superPoweredMusic
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    

    // MARK: - Waveform
    
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let songVC = segue.destinationViewController as? SongViewController{
//            songVC.superPowered = self.superPoweredMusic
//        }
    }
 

}
