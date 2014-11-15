//
//  ViewController.swift
//  Timetabler
//
//  Created by Daniel Koehler on 16/10/2014.
//  Copyright (c) 2014 DanielKoehler. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

extension UIColor {
    func blendWithColor(color2:UIColor, alpha alpha2:CGFloat) -> UIColor
    {
        
        let alpha2 = min( 1.0, max( 0.0, alpha2 ) );
        
        let beta = 1.0 - alpha2
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        self.getRed(&r1, green:&g1, blue:&b1, alpha:&a1)
        color2.getRed(&r2, green:&g2, blue:&b2, alpha:&a2)
        
        let red     = r1 * beta + r2 * alpha2
        let green   = g1 * beta + g2 * alpha2
        let blue    = b1 * beta + b2 * alpha2
        let alpha   = a1 * beta + a2 * alpha2
        
        return UIColor(red: red, green:green, blue:blue, alpha:alpha)
    }
    
}

extension CGColor {
    
    class func grandientLight() -> [CGColor] {return [UIColor(red: 0.353, green: 0.784, blue: 0.984, alpha: 1).CGColor, UIColor(red: 0.322, green: 0.929, blue: 0.78, alpha: 1).CGColor]}
    
    class func grandientDark() -> [CGColor] {return [UIColor(red: 1, green: 0.369, blue: 0.227, alpha: 1).CGColor, UIColor(red: 1, green: 0.165, blue: 0.408, alpha: 1).CGColor]}
    
    class func colorArrayByBlend(firstArray:[CGColor], secondArray:[CGColor], a:CGFloat) -> [CGColor] {
        
        var c1 = UIColor(CGColor: firstArray[0]).blendWithColor(UIColor(CGColor: secondArray[0]), alpha: a).CGColor
        var c2 = UIColor(CGColor: firstArray[1]).blendWithColor(UIColor(CGColor: secondArray[1]), alpha: a).CGColor
    
        return [c1, c2]
        
    }
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout, TimetableDelegate,  MKMapViewDelegate,  CLLocationManagerDelegate {
    
    let linearUrgencyLabels = ["No Rush", "Cutting It Close", "Leave now!", "Run There!", "Fly you fool!"]

    var timetabler = Timetabler.sharedInstance
    var eventProgressView: EventProgressView?
    var eventStatsView: EventStatsView?
    var collectionView: UICollectionView?
    var urgencyLabel = UIButton()
    var gradient = CAGradientLayer()
    var timer:NSTimer?
    
    var locationManager: CLLocationManager?
    var mapView: MKMapView?
    
    var dayLabel = UILabel()
    var timeLabel = UILabel()
    
    private var urgency:CGFloat = 0.0
    
    /*
    * Timetable Delegate Methods
    */
    
    
    func eventDidChange(event:TTEvent) {
        
    }
    
    func timetableDidBeginNetworkActivity() {
        
    }
    
    func timetableDidEndNetworkActivity() {
        
    }
    
    func timetableDidGetEvents() {
        
        // self.setUp()
        
    }
    
    /*
    * VC Methods
    */

    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.requestAlwaysAuthorization()
        locationManager!.startMonitoringSignificantLocationChanges()
        
        // Interval should be greater than animation
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("evaluateUrgency"), userInfo: nil, repeats: true)
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated:false)
        
        self.timetabler.timetable.delegate = self
        self.setUpMainUI()
    
    }

    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        
        timetabler.timetable.updateLocation(newLocation.coordinate)
        
        
    }
    
    
    func  directions () {
        
        self.navigationController?.pushViewController(MapViewController(), animated: true)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.alpha = 0.8
        self.navigationItem.title = "Timetabler"
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.353, green: 0.784, blue: 0.984, alpha: 0.5)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.translucent = true
    
    }

    func setUpMainUI() {
        
        println("Setting up UI")
        
        gradient.frame = self.view.frame
        gradient.colors = CGColor.grandientLight()
        view.layer.insertSublayer(gradient, atIndex: 0)
        
        var text = linearUrgencyLabels[Int(round(Double(urgency) * Double(linearUrgencyLabels.count - 1)))]
        urgencyLabel.setTitle(text, forState: UIControlState.Normal)
        urgencyLabel.setTitle("No Rush", forState: UIControlState.Normal)
        
        let offset = UIApplication.sharedApplication().statusBarFrame.size.height + 5
        
        
        var settingsButton = UIBarButtonItem(title:"Settings", style:UIBarButtonItemStyle.Plain, target:self, action:Selector("menuButtonWasPressed:"))
        self.navigationItem.rightBarButtonItem = settingsButton;
        
        
        urgencyLabel.frame = CGRectMake(0, 0, 100, 25)
        urgencyLabel.center = CGPointMake(self.view.center.x, self.view.frame.height - 165)
        urgencyLabel.backgroundColor = UIColor(white: 1, alpha: 0.2)
        urgencyLabel.layer.cornerRadius = 8
        urgencyLabel.layer.masksToBounds = true
        urgencyLabel.titleLabel?.textColor = UIColor.whiteColor()
        urgencyLabel.titleLabel?.textAlignment = NSTextAlignment.Center
        urgencyLabel.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        urgencyLabel.addTarget(self, action: Selector("showUrgencyExplanation"), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(urgencyLabel)
        
        var directionLabel = UIButton()
        directionLabel.frame = CGRectMake(0,0, 100, 14)
        directionLabel.center = CGPointMake(self.view.center.x + 5, self.view.frame.height - 97)
        directionLabel.titleLabel?.textColor = UIColor.whiteColor()
        directionLabel.titleLabel?.textAlignment = NSTextAlignment.Left
        directionLabel.titleLabel?.font = UIFont.boldSystemFontOfSize(10)
        directionLabel.addTarget(self, action: Selector("directions"), forControlEvents: UIControlEvents.TouchUpInside)
        directionLabel.setTitle("Directions", forState: UIControlState.Normal)
        
        
        var ioniconiclabel = Ionicons.labelWithIcon(
            iconName: Ionicon.Ios7Location,
            size: 10,
            color: UIColor.whiteColor()
        );
        
        ioniconiclabel.frame = CGRectMake(0,0, 14, 14)
        ioniconiclabel.center = CGPointMake(self.view.center.x - 25, self.view.frame.height - 97)
        
        self.view.addSubview(ioniconiclabel)
        self.view.addSubview(directionLabel)
    
        eventProgressView = EventProgressView(frame: CGRectMake(60, 140, 200, 200))
        
        let prev = self.timetabler.timetable.previousEvent()
        let current = self.timetabler.timetable.currentEvent()
        
        println("Would seem to have pre updated")
        eventProgressView!.update(prev, events:self.timetabler.timetable.eventsInbetween(prev.end, end: current.end))
        println("Would seem to have finished updating")
        
        updateDateLabels(self.timetabler.timetable.currentEvent())
        
        self.view.addSubview(eventProgressView!)

        
        dayLabel.frame = CGRectMake(10, self.view.frame.height - 104, 100, 14)
        dayLabel.font = UIFont.boldSystemFontOfSize(10)
        dayLabel.textColor = UIColor.whiteColor()
        view.addSubview(dayLabel)
        
        timeLabel.frame = CGRectMake(self.view.frame.width - 110, self.view.frame.height - 104, 100, 14)
        timeLabel.font = UIFont.boldSystemFontOfSize(10)
        timeLabel.textColor = UIColor.whiteColor()
        timeLabel.textAlignment = NSTextAlignment.Right
        view.addSubview(timeLabel)
        
        self.setUpCollectionView()
        

    }
    
    func showUrgencyExplanation() {
        
        if timetabler.timetable.eventRoute == nil {
            return
        }
        
        let text = "It starts in \(Int(round(timetabler.timetable.tMinusNow / 60))) minutes and it will take you about \(Int(round(timetabler.timetable.eventRoute!.expectedTravelTime / 60))) minutes to walk there!"
        var title = linearUrgencyLabels[Int(round(Double(urgency) * Double(linearUrgencyLabels.count - 1)))]
        
        let alertController = UIAlertController(title: title, message:
            text, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    
    }
    
    private func quantifiyUrgency() {
        
        if(timetabler.timetable.eventRoute != nil){
            
            var reasonableLeeway : NSTimeInterval = 60 * 10
            
            var tRelative = timetabler.timetable.tRelative
            var tMinusNow = timetabler.timetable.tMinusNow
            
            if (tRelative <  0){
                
                self.urgency = CGFloat(max(0, min(abs(tRelative) / tMinusNow, NSTimeInterval(1))))
                
            } else {
                urgency = 0
            }

        }
        
    }
    
    func evaluateUrgency() {
        
        self.quantifiyUrgency()
        
        var index = Int(round(Double(urgency) * Double(linearUrgencyLabels.count - 1)))
        var text = linearUrgencyLabels[index]
        
        urgencyLabel.setTitle(text, forState: UIControlState.Normal)
        
        let s1 = UIColor(red: 0.322, green: 0.929, blue: 0.78, alpha: 1)
        let s2 = UIColor(red: 0.353, green: 0.784, blue: 0.984, alpha: 1)
        let e1 = UIColor(red: 1, green: 0.369, blue: 0.227, alpha: 1)
        let e2 = UIColor(red: 1, green: 0.165, blue: 0.408, alpha: 1)
            
        var fromColors = self.gradient.colors as [CGColor];
        var toColors = CGColor.colorArrayByBlend(fromColors, secondArray: CGColor.grandientDark(), a: self.urgency)
        
        
        if self.urgency > 0.5 {
            self.navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 0.369, blue: 0.227, alpha: 1)
        }
        
        var animation = CABasicAnimation(keyPath: "colors")
        
        gradient.colors = toColors
        
        animation.fromValue = fromColors
        animation.toValue = toColors;
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.delegate = self
        animation.duration = 1
            
        self.gradient.addAnimation(animation, forKey: "animateGradient")
        
        // Add the animation to our layer
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        
        // DID CHANGE BACKGROUND
        
    }
    
    /*
    * Collection View Methods
    */

    
    func setUpCollectionView()
    {
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView = UICollectionView(frame: CGRectMake(0, self.view.frame.height - 80, self.view.frame.width, 80), collectionViewLayout: layout)
        
        collectionView!.delegate = self
        collectionView!.showsHorizontalScrollIndicator = false
        collectionView!.dataSource = self
        collectionView!.pagingEnabled = true
        collectionView!.registerNib(UINib(nibName: "EventViewCell", bundle: nil), forCellWithReuseIdentifier: "eventCell")
        collectionView!.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        
        self.view.addSubview(collectionView!)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

    
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("eventCell", forIndexPath: indexPath) as EventViewCell
        
        cell.setEvent(timetabler.timetable.nthEvent(indexPath.row))
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return collectionView.frame.size
        
    }
    
    func updateDateLabels(event:TTEvent) {
        
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "H:mm"
        
        let start = dateFormater.stringFromDate(event.start).uppercaseString
        let end = dateFormater.stringFromDate(event.end).uppercaseString
        timeLabel.text = "\(start) - \(end)"
        
        
        dateFormater.dateFormat = "EEEE"
        let day = dateFormater.stringFromDate(event.start).uppercaseString
        dayLabel.text = day
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        var event = (self.collectionView!.visibleCells()[0] as EventViewCell).event!
        
        var prev = self.timetabler.timetable.previousEvent()
        var events = self.timetabler.timetable.eventsInbetween(prev.end, end: event.end)
        
        eventProgressView!.update(prev, events:events)
        updateDateLabels(event)

    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return timetabler.timetable.size()
    
    }
    
    func menuButtonWasPressed(sender:UIButton) {
        
        self.navigationController?.pushViewController(SettingsViewController(), animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

