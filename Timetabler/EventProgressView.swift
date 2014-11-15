//
//  EventProgressView.swift
//  Timetabler
//
//  Created by Daniel Koehler on 30/10/2014.
//  Copyright (c) 2014 DanielKoehler. All rights reserved.
//

import UIKit
import Foundation

extension String {
    static func stringFromSeconds(seconds:Double) -> String
    {
        
        var difference = abs(seconds)
        
        var periods = ["sec", "min", "hour", "day", "week", "month", "year", "decade"]
        var lengths = [60, 60, 24, 7, 4.35, 12, 10]
        
        var j = 0;
        
        for(j = 0; difference >= lengths[j]; j++)
        {
            difference = difference / lengths[j]
        }
        
        difference = round(difference);
        
        if(difference != 1)
        {
            periods[j] = periods[j].stringByAppendingString("s")
        }
        
        return "\(Int(difference)) \(periods[j])"
        
    }
}

class  EPEvent {
    
    var progressLayer: CAShapeLayer
    var labelLayer: CAShapeLayer
    var event: TTEvent
    
    init(event:TTEvent) {
        
        self.event = event
        self.progressLayer = CAShapeLayer()
        self.labelLayer = CAShapeLayer()
        
    }
}

class EventProgressView: UIView {
    
    /*
    * kUI
    */
    
    let progressColour = UIColor(white: 1, alpha: 0.6)
    let backColour = UIColor(white: 1, alpha: 0.2)
    let textColour = UIColor.whiteColor()
    let lineWidth = CGFloat(20)
    private var initialised = false
    
    /*
    * Chart References
    */
    
    var displayLink = CADisplayLink()
    
    var timeLayer:CAShapeLayer = CAShapeLayer()
    
    var startLabelLayer:CAShapeLayer = CAShapeLayer()
    var endLabelLayer:CAShapeLayer = CAShapeLayer()
    
    var progress:CGFloat = 0.0
    var timer:NSTimer?
    
    var timeRemainingLabel = UILabel()
    var eventLocationLabel = UILabel()
    var eventDurationLabel = UILabel()
    
    var startContextUILabel = UILabel()
    var endContextUILabel = UILabel()
    
    /*
    * Events References
    */
    
    var contextEvent: TTEvent?
    var events:[EPEvent]?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.initalise()
        
    }
    
    private func initalise() {
        
        self.backgroundColor = UIColor.clearColor()
        
        timeRemainingLabel.textAlignment = NSTextAlignment.Center
        timeRemainingLabel.textColor = textColour
        timeRemainingLabel.frame.size = CGSizeMake(120, 20)
        timeRemainingLabel.center = CGPointMake(self.frame.width / 2,  70)
        timeRemainingLabel.font = UIFont.systemFontOfSize(14)
        
        eventLocationLabel.textAlignment = NSTextAlignment.Center
        eventLocationLabel.textColor = textColour
        eventLocationLabel.frame.size = CGSizeMake(150, 35)
        eventLocationLabel.font = UIFont.systemFontOfSize(32)
        eventLocationLabel.center = CGPointMake(self.frame.width / 2,  self.frame.height / 2)
        
        eventDurationLabel.textAlignment = NSTextAlignment.Center
        eventDurationLabel.textColor = textColour
        eventDurationLabel.frame.size = CGSizeMake(120, 20)
        eventDurationLabel.font = UIFont.systemFontOfSize(11)
        eventDurationLabel.center = CGPointMake(self.frame.width / 2,  130)
        
        self.events = []
        
        self.addSubview(timeRemainingLabel)
        self.addSubview(eventLocationLabel)
        self.addSubview(eventDurationLabel)
        
        var background: CAShapeLayer = CAShapeLayer()
        
        createRingLayerWithCenter(&background, center:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2), radius: CGRectGetWidth(self.bounds) / 2 - lineWidth / 2, lineWidth: lineWidth, colour: self.backColour)
        
        self.layer.addSublayer(background)
        
        createRingLayerWithCenter(&timeLayer, center:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2), radius: CGRectGetWidth(self.bounds) / 2 - lineWidth / 2 - (lineWidth / 2) - 1, lineWidth: 5, colour: UIColor.whiteColor())
        timeLayer.strokeEnd = 0
        self.layer.addSublayer(timeLayer)
        
        var circleBreak = UIBezierPath()
        circleBreak.moveToPoint(CGPointMake(0, -30))
        circleBreak.addLineToPoint(CGPointMake(0, 2))
        
        var layer = CAShapeLayer()
        layer.frame = CGRectMake(CGRectGetWidth(self.frame) / 2, self.frame.origin.x - 35, 2, 32)
        layer.strokeColor = UIColor.whiteColor().CGColor
        layer.lineWidth = 2
        layer.path = circleBreak.CGPath
        
        let contextLabelWidth:CGFloat = 110
        
        endContextUILabel.frame = CGRectMake(CGRectGetWidth(self.frame) / 2 - (80 + contextLabelWidth), -10, contextLabelWidth, 20)
        endContextUILabel.textAlignment = NSTextAlignment.Right
        endContextUILabel.textColor = self.textColour
        endContextUILabel.font = UIFont.systemFontOfSize(12)
        
        startContextUILabel.frame = CGRectMake(CGRectGetWidth(self.frame) / 2 + 80, -10, contextLabelWidth, 20)
        startContextUILabel.textColor = self.textColour
        startContextUILabel.font = UIFont.systemFontOfSize(12)
        
        self.layer.addSublayer(layer)
        
        
    }
    
    func update(contextEvent:TTEvent, events:[TTEvent]) {
        
        if events.count < 1 {
            return
        }
        
        if(!initialised) {
            self.hidden = false
            self.initialised = true
        }
        
        self.contextEvent = contextEvent
        self.addEvents(events)
        
        self.updateViewForEventChange()
        self.setUpRingLayers()
        self.updateView()
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateView"), userInfo: nil, repeats: true)
        
    }
    
    
    private func addEvents(events: [TTEvent]){
        
        for var i = 0; i < self.events!.count; i++ {
            
            var c = false
            
            for event in events { // Check if the `new` event is really new
                
                if self.events![i].event.oid == event.oid { // It's not new
                    c = true
                }
            }
            
            if !c {
                
                self.events![i].progressLayer.strokeStart = self.events![i].progressLayer.strokeEnd
                self.events![i].labelLayer.path = nil
                self.events![i].labelLayer.removeFromSuperlayer()
                self.events!.removeAtIndex(i)
                
            }
        
        }
        
        for event in events {
            
            var contains = false
            
            for e in self.events! {
                if e.event.oid == event.oid {
                    contains = true
                }
            }
            
            if (!contains){
                
                self.events!.append(EPEvent(event: event))
                layer.addSublayer(self.events!.last!.labelLayer)
                layer.addSublayer(self.events!.last!.progressLayer)
                
            }
        }
        
    }
    
    private func updateViewForEventChange() {
        
        var firstEvent = self.events![0].event // Always get locational info for next upcoming event
        eventLocationLabel.text = firstEvent.shortLocation()
        eventDurationLabel.text = "for \(String.stringFromSeconds(firstEvent.start.timeIntervalSinceDate(firstEvent.end)))".uppercaseString
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EE ha"
        
        var start = dateFormatter.stringFromDate(contextEvent!.end)
        var end = dateFormatter.stringFromDate(events!.last!.event.end)
        
        let i = 0
        let x = 90 * CGFloat(cos(Double(i - 90) / 180 * M_PI )) + 100
        let y = 90 * CGFloat(sin(Double(i - 90) / 180 * M_PI )) + 100
        
        //        createLabel(&startLabelLayer, position:CGPointMake(x + 10, y), degrees: Double(45), length: 30, text:"\(start)")
        //        createLabel(&endLabelLayer, position:CGPointMake(x - 10, y), degrees: Double(135), length: 30, text:"\(end)")
        
        startContextUILabel.text = start
        endContextUILabel.text = end
        
        layer.addSublayer(startLabelLayer)
        layer.addSublayer(endLabelLayer)
        
    }
    
    func setUpRingLayers() {
        
        var colours = [UIColor(white: 1, alpha: 0.8).CGColor, UIColor(white: 1, alpha: 0.7).CGColor]
        
        for var i = 0; i < events!.count; i++ {
            
            let centrePoint = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)
            
            createRingLayerWithCenter(&events![i].progressLayer, center:centrePoint, radius:CGRectGetWidth(self.bounds) / 2 - lineWidth / 2, lineWidth:lineWidth, colour:self.progressColour)
            
            events![i].progressLayer.strokeColor = colours[i % 2]
            events![i].progressLayer.strokeEnd = 0
        }
        
    }
    
    func updateView() {
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE ha"
        
        var day = dateFormatter.stringFromDate(contextEvent!.end)
        timeRemainingLabel.text = "\(String.stringFromSeconds(events![0].event.start.timeIntervalSinceNow))".uppercaseString
        
        for var i = 0; i < events!.count; i++ {
            self.updateSegement(index: i)
        }
        
        let pre = contextEvent!
        let post = events!.last!
        let tb = -post.event.end.timeIntervalSinceDate(pre.end)
        timeLayer.strokeEnd = CGFloat(pre.end.timeIntervalSinceDate(NSDate()) / tb)
        
    }
    
    
    func updateSegement(index i: Int){
        
        var preEvent = contextEvent!
        var lastWrapper = events!.last!
        
        var tb = -lastWrapper.event.end.timeIntervalSinceDate(preEvent.end)
        
        var startFraction = CGFloat(preEvent.end.timeIntervalSinceDate(self.events![i].event.start) / tb)
        var endFraction = CGFloat(preEvent.end.timeIntervalSinceDate(self.events![i].event.end) / tb)
        
        let j = ((startFraction + (endFraction-startFraction) / 2)) * 360 + 180
        let x = 90 * CGFloat(cos(Double(j + 90) / 180 * M_PI )) + 100
        let y = 90 * CGFloat(sin(Double(j + 90) / 180 * M_PI )) + 100
        let deg = atan2(Double(x - 100), Double(y - 100)) * (180.0 / M_PI) - 90

        if -tb < (60 * 60 * 30) {
            events![i].labelLayer.hidden = false
            createLabel(&events![i].labelLayer, position:CGPointMake(x, y), degrees:  deg, length: 16, text:self.events![i].event.module.id)
        } else {
            events![i].labelLayer.hidden = true
        }
            
        if (endFraction == 0) {
            
            self.events![i].progressLayer.hidden = true
            
            dispatch_after(UInt64(0.1) * NSEC_PER_SEC, dispatch_get_main_queue(), { () -> Void in
                self.events![i].progressLayer.strokeEnd = 0
            })
            
        } else {
            
            events![i].progressLayer.hidden = false;
            events![i].progressLayer.strokeStart = startFraction
            events![i].progressLayer.strokeEnd = endFraction
            
        }
    }
    
    private func createRingLayerWithCenter(inout slice:CAShapeLayer, center:CGPoint, radius:CGFloat, lineWidth: CGFloat, colour:UIColor)  {
        
        var smoothedPath = UIBezierPath(arcCenter: CGPointMake(radius, radius), radius: radius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(M_PI + M_PI_2), clockwise: true)

        slice.contentsScale = UIScreen.mainScreen().scale
        slice.frame = CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2)
        slice.fillColor = UIColor.clearColor().CGColor
        slice.strokeColor = colour.CGColor
        slice.lineWidth = lineWidth
        slice.lineCap = kCALineJoinBevel
        slice.lineJoin = kCALineJoinBevel
        slice.path = smoothedPath.CGPath
        
    }
    
    private func createLabel(inout labelView:CAShapeLayer, position:CGPoint, var degrees: Double, length: CGFloat, text:String) {
        
        labelView.sublayers = nil
        
        var circleSize:CGFloat = 4
        var r = circleSize / 2
        var angle = -degrees / 180 * M_PI
        
        var circle = UIBezierPath(ovalInRect: CGRectMake(0, 0, circleSize, circleSize))
        var x = r * CGFloat(cos(angle)) + r; var y = r * CGFloat(sin(angle)) + r;
        
        circle.moveToPoint(CGPointMake(x, y))
        
        var extrusion = CGPointMake(length * CGFloat(cos(angle)) + r, length * CGFloat(sin(angle)) + r)
        
        circle.addLineToPoint(extrusion)
        
        labelView.path = circle.CGPath
        labelView.lineWidth = 1
        labelView.fillColor = UIColor.clearColor().CGColor
        labelView.strokeColor = UIColor.whiteColor().CGColor
        
        labelView.position = CGPointMake(position.x - r, position.y - r)
        
        var textLabel = CATextLayer()
        
        var lp = CGPointMake((length + 10) * CGFloat(cos(angle)) + r, (length + 10) * CGFloat(sin(angle)) + r)
        degrees = angle * 180 / M_PI + 90
        
        
        if 10 <= degrees && degrees <= 180  {
            
            textLabel.alignmentMode = kCAAlignmentLeft
            textLabel.frame = CGRectMake(lp.x, lp.y - 6, 60, 10)
            
        } else if 190 <= degrees && degrees <= 360 || degrees < 10    {
            
            textLabel.alignmentMode = kCAAlignmentRight
            textLabel.frame = CGRectMake(lp.x - 60, lp.y - 3, 60, 10)
            
        } else {
            
            textLabel.alignmentMode = kCAAlignmentCenter
            textLabel.frame = CGRectMake(lp.x, lp.y - 6, 60, 10)
            
        }
        
        textLabel.string = text.uppercaseString
        textLabel.fontSize = 10
        textLabel.contentsScale = UIScreen.mainScreen().scale
        labelView.addSublayer(textLabel)
        
    }
    
    
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
}
