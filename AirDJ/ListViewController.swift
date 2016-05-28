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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSongButton.layer.cornerRadius = addSongButton.frame.height / 2
        addSongButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.6).CGColor
        addSongButton.layer.borderWidth = 1.0
        addSongButton.layer.masksToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = nil
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - TableView Data Source/ Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        cell.backgroundColor = nil
        if indexPath.row % 2 == 0{
            cell.backgroundColor = UIColor.whiteColor()
        }else{
            cell.backgroundColor = UIColor(red: 0.941, green: 0.945, blue: 0.961, alpha: 1.00)
        }
        
        let numberLabel = UILabel(frame: CGRectMake(0,0, cell.frame.height, cell.frame.height))
         numberLabel.textAlignment = .Center
        numberLabel.text = "\(indexPath.row)"
        numberLabel.textColor = UIColor(red: 0.173, green: 0.804, blue: 0.820, alpha: 1.00)
        numberLabel.font = UIFont(name: "Panton-Regular", size: 40)
        numberLabel.sizeToFit()
        numberLabel.center = CGPointMake(cell.frame.height / 2 + 10, cell.frame.height / 2)
        cell.addSubview(numberLabel)
        
        
        
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
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
