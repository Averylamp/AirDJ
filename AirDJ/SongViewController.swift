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
    @IBOutlet weak var infoLabel: UILabel!
    
    var musicIsPlaying = true
    var armString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didConnectDevice), name: TLMHubDidConnectDeviceNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didDisconnectDevice), name: TLMHubDidDisconnectDeviceNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didSyncArm), name: TLMMyoDidReceiveArmSyncEventNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didUnsyncArm), name: TLMMyoDidReceiveArmUnsyncEventNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReceiveOrientationEvent), name: TLMMyoDidReceiveOrientationEventNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReceiveAccelerometerEvent), name: TLMMyoDidReceiveAccelerometerEventNotification, object: nil)
        let displayLink = CADisplayLink(target: self, selector: #selector(SongViewController.frameUpdate))
        displayLink.frameInterval = 3
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
        waveform1.geometryFlipped = true
        waveform2.geometryFlipped = true
        waveform3.geometryFlipped = true
        waveform1.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height / 2)
        waveform1.strokeColor = UIColor(white: 1.0, alpha: 1.0).CGColor
        waveform1.lineWidth = 2
        waveform1.fillColor = nil
        self.view.layer.addSublayer(waveform1)
        waveform2.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height / 2)
        waveform2.strokeColor = UIColor(white: 1.0, alpha: 0.6).CGColor
        waveform2.lineWidth = 2
        waveform2.fillColor = nil
        self.view.layer.addSublayer(waveform2)
        waveform3.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height / 2)
        waveform3.strokeColor = UIColor(white: 1.0, alpha: 0.2).CGColor
        waveform3.lineWidth = 2
        waveform3.fillColor = nil
        self.view.layer.addSublayer(waveform3)
        
    }
    var waveform1 = CAShapeLayer()
    var waveform2 = CAShapeLayer()
    var waveform3 = CAShapeLayer()
    
    func didConnectDevice (notif: NSNotification) {
        infoLabel.text = "Perform the Sync Gesture"
    }
    
    func didDisconnectDevice (notif: NSNotification) {
        infoLabel.text = "Reconnect Myo"
    }
    
    func didSyncArm (notif: NSNotification) {
        let armEvent = notif.userInfo![kTLMKeyArmSyncEvent] as! TLMArmSyncEvent
        let armString = armEvent.arm == .Right ? "Right" : "Left"
        infoLabel.text = armString
    }
    
    func didUnsyncArm (notif: NSNotification) {
        infoLabel.text = "Perform the Sync Gesture"
    }
    
    func didReceiveOrientationEvent (notif: NSNotification) {
        let orientationEvent = notif.userInfo![kTLMKeyOrientationEvent] as! TLMOrientationEvent
    }
    
    func didReceiveAccelerometerEvent (notif: NSNotification) {
        let accelerometerEvent = notif.userInfo![kTLMKeyAccelerometerEvent] as! TLMAccelerometerEvent
    }
    
    var superPowered: Superpowered? = nil
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        superPowered = nil
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func playButtonTapped(sender: AnyObject) {
//        if superPowered == nil{
//            superPowered = Superpowered()
//            superPowered?.toggle()
//            
//        }
        superPowered?.togglePlayback()
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
    
    
    func frameUpdate(){
        
        superPowered?.getFrequencies(NSMutableArray(array: [55,77, 110,155, 220,311, 440, 622, 880,1244, 1760,2489, 3520,4978, 7040,9956]))
        let frequencies =  superPowered?.frequenciesArr
        if frequencies == nil {
            return
        }
        
        var scaleFactor = 1000.0
        var scaledFrequencies = Array<Double>()
        for num in frequencies! {
            scaledFrequencies.append(Double(num as! NSNumber) * scaleFactor)
        }
        var allPoints = Array<CGPoint>()
        for i in 0..<scaledFrequencies.count{
            allPoints.append(CGPointMake(self.view.frame.width * CGFloat(i) / CGFloat(scaledFrequencies.count - 1), CGFloat(scaledFrequencies[i])))
        }
        print(allPoints)
        
        var secondPoints = Array<CGPoint>()
        for i in 0..<allPoints.count{
            secondPoints.append(CGPointMake(self.view.frame.width * CGFloat(i) / CGFloat(scaledFrequencies.count - 1), CGFloat(scaledFrequencies[i] * 0.8)))
        }
        
        var thirdPoints = Array<CGPoint>()
        for i in 0..<allPoints.count{
            thirdPoints.append(CGPointMake(self.view.frame.width * CGFloat(i) / CGFloat(scaledFrequencies.count - 1), CGFloat(scaledFrequencies[i] * 0.6)))
        }
        
        let endPath = UIBezierPath()
        endPath.contractionFactor = 0.7
        endPath.moveToPoint(allPoints.first!)
        endPath.addBezierThrough(allPoints)
        
        var animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = waveform1.path
        animation.toValue = endPath.CGPath
        animation.duration = 3.0 / 60.0
        waveform1.path = endPath.CGPath
        waveform1.addAnimation(animation, forKey: "waveAnimation")

        let endPath2 = UIBezierPath()
        endPath2.contractionFactor = 0.7
        endPath2.moveToPoint(secondPoints.first!)
        endPath2.addBezierThrough(secondPoints)
        
        animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = waveform2.path
        animation.toValue = endPath2.CGPath
        animation.duration = 3.0 / 60.0
        waveform2.path = endPath2.CGPath
        waveform2.addAnimation(animation, forKey: "waveAnimation")

        
        let endPath3 = UIBezierPath()
        endPath3.contractionFactor = 0.7
        endPath3.moveToPoint(thirdPoints.first!)
        endPath3.addBezierThrough(thirdPoints)
        
        animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = waveform3.path
        animation.toValue = endPath3.CGPath
        animation.duration = 3.0 / 60.0
        waveform3.path = endPath3.CGPath
        waveform3.addAnimation(animation, forKey: "waveAnimation")

    }
    
    
    
    func quadCurvedPath(points: Array<CGPoint>) -> UIBezierPath {
        let path = UIBezierPath()
        
        var p1 = points[0]
        path.moveToPoint(p1)
        for i in 1..<points.count {
            let p2 = points[i]
            let midPoint = midpointOfPoints(p1, secondPoint: p2)
            path.addQuadCurveToPoint(midPoint, controlPoint: controlPointForPoints(p1, p2: midPoint))
            path.addQuadCurveToPoint(p2, controlPoint: controlPointForPoints(midPoint, p2: p2))
            p1 = p2
        }
        return path
        
    }
    
    private func midpointOfPoints(firstPoint: CGPoint, secondPoint:CGPoint)->CGPoint{
        return CGPointMake((firstPoint.x + secondPoint.x) / 2, (firstPoint.y + secondPoint.y) / 2)
    }
    
    private func controlPointForPoints(p1: CGPoint, p2: CGPoint)-> CGPoint{
        var controlPoint = midpointOfPoints(p1, secondPoint: p2)
        let diffy = abs((p2.y - controlPoint.y))
        if p1.y < p2.y {
            controlPoint.y += diffy
        }else if p1.y > p2.y{
            controlPoint.y  -= diffy
        }
        return controlPoint
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
