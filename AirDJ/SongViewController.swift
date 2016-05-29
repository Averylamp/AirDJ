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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReceivePoseChange), name: TLMMyoDidReceivePoseChangedNotification, object: nil)

        let displayLink = CADisplayLink(target: self, selector: #selector(SongViewController.frameUpdate))
        displayLink.frameInterval = 3
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
        let numberOfLines = 20
        for i in 0...numberOfLines {
            let waveform = CAShapeLayer()
            waveforms.append(waveform)
            waveform.geometryFlipped = true
            waveform.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height / 3)
            waveform.strokeColor = UIColor(white: 1.0, alpha:  (CGFloat(Double(i ) *  0.5 / Double(numberOfLines)))).CGColor
            waveform.lineWidth = 2
            waveform.fillColor = nil
            self.view.layer.addSublayer(waveform)
        }

        

    }
    
    var waveforms = Array<CAShapeLayer>()
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
        let vector = accelerometerEvent.vector
        let x = round(vector.x*1000)/1000
        let y = round(vector.y*1000)/1000
        let z = round(vector.z*1000)/1000
//        infoLabel.text = "x: \(x), y: \(y), z: \(z)"
        infoLabel.text = "\(y)"
    }
    
    var superPowered: Superpowered? = nil
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        superPowered = nil
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func didReceivePoseChange (notif: NSNotification) {
        let pose = notif.userInfo![kTLMKeyPose] as! TLMPose
        switch (pose.type) {
            case .Unknown, .Rest:
                break;
            case .DoubleTap:
                break;
            case .Fist:
                break;
            case .WaveIn:
                break;
            case .WaveOut:
                break;
            case .FingersSpread:
                break;
        }

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
        
        superPowered?.getFrequencies(NSMutableArray(array: [55, 65,77,92, 110,131, 155,184, 220,262, 311,370, 440,523, 622,740, 880,951, 1244,1479, 1760, 2093, 2489, 2960, 3520, 4186, 4978, 5920, 7040, 8372, 9956, 11840]))
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
        
        var points = Array<Array<CGPoint>>()
        for i in 0..<waveforms.count{
            var pointArr = Array<CGPoint>()
            for g in 0..<allPoints.count{
                pointArr.append(CGPointMake(allPoints[g].x, allPoints[g].y * CGFloat(Double(i) / Double(waveforms.count - 1))))
            }
            points.append(pointArr)
        }
//        
//        var firstPoints = Array<CGPoint>()
//        for i in 0..<allPoints.count{
//            firstPoints.append(CGPointMake(self.view.frame.width * CGFloat(i) / CGFloat(allPoints.count - 1), CGFloat(scaledFrequencies[i ])))
//        }
//        
//        var secondPoints = Array<CGPoint>()
//        for i in 0...11{
//            secondPoints.append(CGPointMake(self.view.frame.width * CGFloat(i) / CGFloat(5), CGFloat(scaledFrequencies[i + 10])))
//        }
//        
//        var thirdPoints = Array<CGPoint>()
//        for i in 0...11{
//            thirdPoints.append(CGPointMake(self.view.frame.width * CGFloat(i) / CGFloat(5), CGFloat(scaledFrequencies[i + 20])))
//        }
//
        for i in 0..<waveforms.count{
            let endPath = UIBezierPath()
            endPath.contractionFactor = 0.7
            endPath.moveToPoint(points[i].first!)
            endPath.addBezierThrough(points[i])
            
            
            var animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = waveforms[i]
            animation.toValue = endPath.CGPath
            animation.duration = 3.0 / 60.0
            waveforms[i].path = endPath.CGPath
            waveforms[i].addAnimation(animation, forKey: "waveAnimation")
            
        }

//        let endPath2 = UIBezierPath()
//        endPath2.contractionFactor = 0.7
//        endPath2.moveToPoint(secondPoints.first!)
//        endPath2.addBezierThrough(secondPoints)
//        
//        animation = CABasicAnimation(keyPath: "path")
//        animation.fromValue = waveform2.path
//        animation.toValue = endPath2.CGPath
//        animation.duration = 3.0 / 60.0
//        waveform2.path = endPath2.CGPath
//        waveform2.addAnimation(animation, forKey: "waveAnimation")
//        
//        let endPath3 = UIBezierPath()
//        endPath3.contractionFactor = 0.7
//        endPath3.moveToPoint(thirdPoints.first!)
//        endPath3.addBezierThrough(thirdPoints)
//        
//        animation = CABasicAnimation(keyPath: "path")
//        animation.fromValue = waveform3.path
//        animation.toValue = endPath3.CGPath
//        animation.duration = 3.0 / 60.0
//        waveform3.path = endPath3.CGPath
//        waveform3.addAnimation(animation, forKey: "waveAnimation")

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
