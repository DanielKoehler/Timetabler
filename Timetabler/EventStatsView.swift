//
//  EventStatsView.swift
//  Timetabler
//
//  Created by Daniel Koehler on 01/11/2014.
//  Copyright (c) 2014 DanielKoehler. All rights reserved.
//

import UIKit
import Foundation

class EventStatsView: UIView {
    
    /*
    * Events References
    */
    
    var event: TTEvent? {
        didSet {
            self.updateStats()
        }
    }
    
    let statWidth:CGFloat = 80
    
    var attendanceLayer:CAShapeLayer
    var punctualityLayer:CAShapeLayer
    
    override init(frame: CGRect) {
        
        self.punctualityLayer = CAShapeLayer()
        self.attendanceLayer = CAShapeLayer()
        
        super.init(frame: frame)
        
        attendanceLayer = createAttendanceLayer()
        punctualityLayer = createPunctualityLayer()
        attendanceLayer.strokeEnd = 0
        punctualityLayer.strokeEnd = 0
        
        var attendenceLabel = UILabel()
        attendenceLabel.text = "attendence".uppercaseString
        attendenceLabel.font = UIFont.systemFontOfSize(8)
        attendenceLabel.frame = CGRectMake(self.center.x + 10, 0, 150,10)
        attendenceLabel.sizeToFit()
        attendenceLabel.textColor = UIColor.whiteColor()
        
        var punctualityLabel = UILabel()
        punctualityLabel.text = "punctuality".uppercaseString
        punctualityLabel.textColor = UIColor.whiteColor()
        punctualityLabel.font = UIFont.systemFontOfSize(8)
        punctualityLabel.textAlignment = NSTextAlignment.Right
        punctualityLabel.frame = CGRectMake(0, 0, 150,10)
        
        self.addSubview(attendenceLabel)
        self.addSubview(punctualityLabel)
        
        self.layer.addSublayer(punctualityLayer)
        self.layer.addSublayer(attendanceLayer)
        
        self.backgroundColor = UIColor(white: 1, alpha: 0.2)
        
        
    }
    
    private func updateStats() {
        
        attendanceLayer.strokeEnd = self.getAttendance()
        punctualityLayer.strokeEnd = self.getPunctuality()
        
    }
    
    private func createAttendanceLayer() -> CAShapeLayer {
        
        
        var path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(statWidth, 0))
        
        var shape = CAShapeLayer(layer:layer)

        shape.path = path.CGPath
        shape.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - 3);
        shape.fillColor = UIColor.clearColor().CGColor;
        shape.strokeColor = UIColor.whiteColor().CGColor;
        shape.lineWidth = 6;
        
        return shape
        
    }
    
    
    private func createPunctualityLayer() -> CAShapeLayer {
        
        var path = UIBezierPath()
        path.moveToPoint(CGPointMake(statWidth, 0))
        path.addLineToPoint(CGPointMake(0, 0))
        
        var shape = CAShapeLayer(layer:layer)
        
        shape.path = path.CGPath
        shape.position = CGPointMake(CGRectGetMidX(self.bounds) - statWidth, CGRectGetMidY(self.bounds) + 3);
        shape.fillColor = UIColor.clearColor().CGColor;
        shape.strokeColor = UIColor.whiteColor().CGColor;
        shape.lineWidth = 6;
        
        return shape
        
    }
    
    private func getAttendance() -> CGFloat {
        
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        
    }
    
    private func getPunctuality() -> CGFloat {
        
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        
    }
    
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
}
