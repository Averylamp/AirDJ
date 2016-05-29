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
    
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var flangerButton: UIButton!
    @IBOutlet weak var loopButton: UIButton!
    @IBOutlet weak var bassBoostButton: UIButton!
    @IBOutlet weak var phaserButton: UIButton!
    @IBOutlet weak var timeShiftButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    
    var toggleButtons = Array<UIButton>()
    
    var musicIsPlaying = true
    var armString = ""
    var currentPose: TLMPose?
    var currentPoseString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleButtons.append(flangerButton)
        toggleButtons.append(loopButton)
        toggleButtons.append(bassBoostButton)
        toggleButtons.append(phaserButton)
        toggleButtons.append(timeShiftButton)
        toggleButtons.append(reverbButton)
        toggleButtons.forEach {
            $0.layer.cornerRadius = 15
            $0.layer.borderColor = UIColor(white: 1.0, alpha: 0.7).CGColor
            $0.layer.borderWidth = 1.0
            $0.clipsToBounds = true
            $0.adjustsImageWhenHighlighted = false
            $0.setTitleColor(UIColor.blackColor(), forState: .Selected)
            $0.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        }
        
        progressView.trackTintColor = UIColor(white: 0.7, alpha: 0.4)
        
        forwardButton.setImage(UIImage(named: "Fast Forward"), forState: .Highlighted)
        backwardButton.setImage(UIImage(named: "Rewind"), forState: .Highlighted)
        
        TLMHub.sharedHub().lockingPolicy = .None
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didConnectDevice), name: TLMHubDidConnectDeviceNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didDisconnectDevice), name: TLMHubDidDisconnectDeviceNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didSyncArm), name: TLMMyoDidReceiveArmSyncEventNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didUnsyncArm), name: TLMMyoDidReceiveArmUnsyncEventNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReceiveOrientationEvent), name: TLMMyoDidReceiveOrientationEventNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReceiveAccelerometerEvent), name: TLMMyoDidReceiveAccelerometerEventNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReceivePoseChange), name: TLMMyoDidReceivePoseChangedNotification, object: nil)

         displayLink = CADisplayLink(target: self, selector: #selector(SongViewController.frameUpdate))
        displayLink!.frameInterval = 3
        displayLink!.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
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
    var displayLink: CADisplayLink? = nil
    var waveforms = Array<CAShapeLayer>()
    
    func didConnectDevice (notif: NSNotification) {
        infoLabel.text = "Perform the Sync Gesture"
    }
    
    func didDisconnectDevice (notif: NSNotification) {
        infoLabel.text = "Reconnect Myo"
    }
    
    func didSyncArm (notif: NSNotification) {
        let armEvent = notif.userInfo![kTLMKeyArmSyncEvent] as! TLMArmSyncEvent
        var armString = ""
        if armEvent.arm == .Right {
            armString = "Right"
        }else{
            armString = "Left"
        }
        infoLabel.text = armString
    }
    
    func didUnsyncArm (notif: NSNotification) {
        infoLabel.text = "Perform the Sync Gesture"
    }
    
    var isBelowPitchLowThreshold = false
    var isAbovePitchLowThreshold = false
    
    func didReceiveOrientationEvent (notif: NSNotification) {
        let orientationEvent = notif.userInfo![kTLMKeyOrientationEvent] as! TLMOrientationEvent
        let angles = TLMEulerAngles(quaternion: orientationEvent.quaternion)
        
        let r = round(angles.roll.degrees*10)/10
        let p = round(angles.pitch.degrees*10)/10
        let y = round(angles.yaw.degrees*10)/10
        
        if isBelowPitchLowThreshold == false && p <= -50 {
            isBelowPitchLowThreshold = true
            pitchShiftTriggered(UIView())
        }else if isBelowPitchLowThreshold == true && p > -50 {
            isBelowPitchLowThreshold = false
            pitchShiftTriggered(UIView())
        }
        
        if isAbovePitchLowThreshold == false && p >= 50 {
            isAbovePitchLowThreshold = true
            timeShiftTriggered(UIView())
        }else if isAbovePitchLowThreshold == true && p < 50 {
            isAbovePitchLowThreshold = false
            timeShiftTriggered(UIView())
        }
        
        print("Roll: \(r)  Pitch: \(p)  Yaw: \(y)")
        if (currentPose != nil) {
            infoLabel.text = "\(currentPoseString) \(p)"
            
        }
    }
    
    func didReceiveAccelerometerEvent (notif: NSNotification) {
        let accelerometerEvent = notif.userInfo![kTLMKeyAccelerometerEvent] as! TLMAccelerometerEvent
        let vector = accelerometerEvent.vector
        let x = round(vector.x*1000)/1000
        let y = round(vector.y*1000)/1000
        let z = round(vector.z*1000)/1000
//        infoLabel.text = "x: \(x), y: \(y), z: \(z)"
//        infoLabel.text = "\(y)"
    }
    
    var superPowered: Superpowered? = nil
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        superPowered = nil
        displayLink?.invalidate()
        displayLink = nil
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func didReceivePoseChange (notif: NSNotification) {
        let pose = notif.userInfo![kTLMKeyPose] as! TLMPose
        currentPose = pose
        switch (pose.type) {
            case .Unknown, .Rest:
                currentPoseString = "Rest"
                break;
            case .DoubleTap:
                currentPoseString = "DoubleTap"
                loopTriggered(UIView())
                break;
            case .Fist:
                currentPoseString = "Fist"
                playButtonTapped(UIButton)
                break;
            case .WaveIn:
                currentPoseString = "WaveIn"
                phaserTriggered(UIView())
                break;
            case .WaveOut:
                currentPoseString = "WaveOut"
                forwardButtonClicked(UIButton)
                break;
            case .FingersSpread:
                flangerTriggered(UIView())
                currentPoseString = "Spread"
                break;
        }
        print(currentPoseString)
    }
    
    //MARK: - Play Functions
    
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
    
    @IBAction func forwardButtonClicked(sender: AnyObject) {
        forwardButton.highlighted = true
        delay(0.4) { 
            self.forwardButton.highlighted = false
        }
        superPowered?.seekTo(min(superPowered!.positionPercent() + 0.02, 1.0))
        print("fast forward")
    }
    
    
    
    @IBAction func rewindButtonClicked(sender: AnyObject) {
        backwardButton.highlighted = true
        delay(0.4) { 
            self.backwardButton.highlighted = false
        }
        superPowered?.seekTo(max(superPowered!.positionPercent() - 0.02, 0.0))
        print("fast forward")
    }
    
    
    func frameUpdate(){
        
        progressView.progress = superPowered!.positionPercent()
        
        superPowered?.getFrequencies(NSMutableArray(array: [55, 65,77,92, 110,131, 155,184, 220,262, 311,370, 440,523, 622,740, 880,951, 1244,1479, 1760, 2093, 2489, 2960, 3520, 4186, 4978, 5920, 7040, 8372, 9956, 11840]))
        let frequencies =  superPowered?.frequenciesArr
        if frequencies == nil {
            return
        }
        
        let scaleFactor = 1000.0
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

        for i in 0..<waveforms.count{
            let endPath = UIBezierPath()
            endPath.contractionFactor = 0.7
            endPath.moveToPoint(points[i].first!)
            endPath.addBezierThrough(points[i])
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = waveforms[i]
            animation.toValue = endPath.CGPath
            animation.duration = 3.0 / 60.0
            waveforms[i].path = endPath.CGPath
            waveforms[i].addAnimation(animation, forKey: "waveAnimation")
        }
    }
    
    // MARK: - Effects
    // 6 is reverb
    //
    
    
    @IBAction func flangerTriggered(sender: AnyObject) {
        print("Flanger Triggered")
        superPowered?.toggleFx(5)
        flangerButton.selected = !flangerButton.selected
        if flangerButton.selected {
            flangerButton.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
        }else{
            flangerButton.backgroundColor = nil
        }
    }
    
    @IBAction func loopTriggered(sender: AnyObject) {
        print("Loop Triggered")
        superPowered?.toggleFx(2)
        loopButton.selected = !loopButton.selected
        if loopButton.selected {
            loopButton.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
        }else{
            loopButton.backgroundColor = nil
        }
    }
    
    @IBAction func bassBoostTriggered(sender: AnyObject) {
        print("Bass Boost Triggered")
        superPowered?.toggleFx(4)
        bassBoostButton.selected = !bassBoostButton.selected
        if bassBoostButton.selected {
            bassBoostButton.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
        }else{
            bassBoostButton.backgroundColor = nil
        }
    }
    
    @IBAction func phaserTriggered(sender: AnyObject) {
        print("Phaser Triggered")
        superPowered?.toggleFx(3)
        phaserButton.selected = !phaserButton.selected
        if phaserButton.selected {
            phaserButton.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
        }else{
            phaserButton.backgroundColor = nil
        }
    }
    
    @IBAction func timeShiftTriggered(sender: AnyObject) {
        print("Time Shift Triggered")
        superPowered?.toggleFx(0)
        timeShiftButton.selected = !timeShiftButton.selected
        if timeShiftButton.selected {
            timeShiftButton.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
        }else{
            timeShiftButton.backgroundColor = nil
        }
    }
    
    @IBAction func pitchShiftTriggered(sender: AnyObject) {
        print("Pitch Shift Triggered")
        superPowered?.toggleFx(6)
        reverbButton.selected = !reverbButton.selected
        if reverbButton.selected {
            reverbButton.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
        }else{
            reverbButton.backgroundColor = nil
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
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
