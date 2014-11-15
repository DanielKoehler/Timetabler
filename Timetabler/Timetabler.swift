//
//  Timetabler.swift
//  Timetabler
//
//  Created by Daniel Koehler on 27/10/2014.
//  Copyright (c) 2014 DanielKoehler. All rights reserved.
//

import UIKit
import AlamoFire
import MapKit


enum TimetableEventRange {
    case Week
    case Month
    case All
}

// CONFORMANCE CHECKING WHEN POSSIBLE

protocol TimetableDelegate {
    
    func eventDidChange(event:TTEvent)
    
    func timetableDidGetEvents()
    
    func timetableDidBeginNetworkActivity()
    func timetableDidEndNetworkActivity()
    
}

class Timetable: NSObject {
    
    private var events: [TTEvent] = []
    private var cEvent: TTEvent?
    var initalised:Bool = false
    var delegate: TimetableDelegate?
    var eventRoute: MKETAResponse?
    
    let startOverride = NSTimeInterval(0) // = NSTimeInterval(60 * 5)  // TESTING ONLY!!!!! weak set of start to be now + 5 minutes
    
    override init() {}
    
    func size() -> Int {
        return events.count
    }
    
    var reasonableLeeway : NSTimeInterval = 0 // 0 Minutes
    
    var tMinusNow: NSTimeInterval {
        
        get {
            var start = currentEvent().start.timeIntervalSinceNow
            if (startOverride > 0){start = startOverride} // TESTING
        
            return start
        }
        
    }
    
    var tRelative: NSTimeInterval {
        
        get {
            var start = currentEvent().start.timeIntervalSinceNow
            if (startOverride > 0){start = startOverride} // TESTING
            
            return start  - eventRoute!.expectedTravelTime
        }
        
    }
    
    func updateLocation(currentLocation:CLLocationCoordinate2D) {
        
        var dr = MKDirectionsRequest()
        
        var cl = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation, addressDictionary: nil))
        cl.name = "Current Location"
        
        var dl = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 51.484410, longitude: -3.169627), addressDictionary: nil))
        dl.name = "Lecture"
        
        dr.setSource(cl)
        dr.setDestination(dl)
        
        dr.transportType = MKDirectionsTransportType.Walking
        var d = MKDirections(request: dr)
        
        d.calculateETAWithCompletionHandler  { (response, error) -> Void in
            
            if ((error) == nil){
                
                self.eventRoute = response
                
            }
        }
    }
    
    func currentEvent() -> TTEvent
    {
        
        if(self.cEvent? == nil || cEvent?.end.timeIntervalSinceNow <= 0){
            cEvent = self.eventsStartingAfter(NSDate(), limit: 1)[0]
        }
        
        return cEvent!
    }
    
    func nthEvent(index: Int) -> TTEvent
    {
        return events[indexForEventWithOid(currentEvent().oid) + index]
    }
    
    func nextEvent() -> TTEvent
    {
        return events[indexForEventWithOid(currentEvent().oid) + 1]
    }
    
    func nextEvent(event:TTEvent) -> TTEvent
    {
        return events[indexForEventWithOid(event.oid) + 1]
    }
    
    func previousEvent() -> TTEvent
    {
        return events[indexForEventWithOid(currentEvent().oid) - 1]
    }
    
    func previousEvent(event:TTEvent) -> TTEvent
    {
        return events[indexForEventWithOid(event.oid) - 1]
    }
    
    func eventsInbetween(start:NSDate, end:NSDate) -> [TTEvent] {
        
        var events: [TTEvent] = []
        let sint = start.timeIntervalSince1970
        let eint = end.timeIntervalSince1970
        
        for (var i = 0; i < self.events.count; i++){
            
            if(self.events[i].start.timeIntervalSince1970 >= sint && self.events[i].end.timeIntervalSince1970 <= eint) {
                events.append(self.events[i])
                
            }
            
        }
        
        return events
        
    }
    
    func eventsEndingAfter(date:NSDate, var limit:Int = 0) -> [TTEvent] {
        
        var events: [TTEvent] = []
        let int = date.timeIntervalSince1970
        
        for (var i = 0; i < self.events.count; i++){
            
            if(self.events[i].end.timeIntervalSince1970 > int) {
                events.append(self.events[i])
                limit--
            }
            
            if (limit == 0){
                return events
            }
        
        }
        
        return events
        
    }
    
    
    func eventsStartingAfter(date:NSDate, var limit:Int = 0) -> [TTEvent] {
     
        var events: [TTEvent] = []
        let int = date.timeIntervalSince1970
        
        for (var i = 0; i < self.events.count; i++){
            
            if(int < self.events[i].start.timeIntervalSince1970) {
                events.append(self.events[i])
                limit--
            }
            
            if (limit == 0){
                return events
            }
            
        }
        
        return events
        
    }
    
    private func insertIndexForDate(date:NSTimeInterval) -> Int {
        
        var index: Int = 0

        for (var i = 0; i < self.events.count; i++){
            if(self.events[i].start.timeIntervalSince1970 > date){
                break
            }
            index++
        }
        
        return index
        
    }
    
    private func indexForEventWithOid(oid:NSString) -> Int {
        
        var i: Int = 0
        
        for (i = 0; i < events.count; i++){
            if(events[i].oid == oid){
                return i
            }
        }
        return -1
        
    }
    
    private func sort(){
        events.sort { (lhs, rhs) in return lhs.start.timeIntervalSince1970 < rhs.start.timeIntervalSince1970 }
    }
    
    private func addEvent(event:TTEvent)
    {

        var i = self.indexForEventWithOid(event.oid)
        
        if(i == -1) {
            self.events.insert(event, atIndex: self.insertIndexForDate(event.start.timeIntervalSince1970))
        } else {
            self.events[i] = event
        }
    
    }
    
    
    func addEvents(events:[TTEvent]) {
        
        for event in events {
            self.addEvent(event)
        }
        
        self.initalised = true
        self.delegate?.timetableDidGetEvents()
        
    }
    
    func addEvents(jsonArray:Array<AnyObject>) {
        
        
        events = []
        
        for event in jsonArray {
            self.events.append(TTEvent(json: event as Dictionary<String,AnyObject>))
        }

        self.sort()
        
        self.initalised = true
        self.delegate?.timetableDidGetEvents()
        
    }


}

@objc protocol TimetablerLoginDelegate {
    
    optional func didFetchUserAuthToken()
    
    optional func didFetchUser()
    
    optional func didFetchTimetable()
    
    optional func TOTPTokenWasInvalid()
    
}

class Timetabler: NSObject {
    
    let clientToken = "FT8FcrOXrQQzmMA6DJnaON7YyrhpISa9HYEuHlUF5Vf0CEryMdJcn1t4oNJmngOZ"
    
    var user: User?
    var timetable = Timetable()
    var loginDelegate: TimetablerLoginDelegate?
    
    override init() {
        
        super.init()
        
    }
    
    func login(TOTPAuthToken:NSString) {
        
        Alamofire.request(.GET, "http://178.62.37.231/api/oauth/user_authtoken", parameters: ["clientToken": self.clientToken, "TOTPAuthToken":  TOTPAuthToken]).responseJSON { (NSURLRequest, NSHTTPURLResponse, JSON, NSError) in

            switch (NSHTTPURLResponse!.statusCode) {
                case 418:
                    self.loginDelegate!.TOTPTokenWasInvalid?()
                case 200:
                    let res = JSON as Dictionary<String,AnyObject>
                    if (res["userAuthToken"] != nil && res["username"] != nil) {
                        
                        self.getUserForToken(res["userAuthToken"] as NSString, username:res["username"] as NSString)
                        self.loginDelegate?.didFetchUserAuthToken?()
                        
                    }
                
                default:
                    fatalError("Unknown Error")
                
            }
            
        }
    }
    
    func getUserForToken(userAuthToken:NSString, username:NSString) {
        
        Alamofire.request(.GET, "http://178.62.37.231/api/user/", parameters: ["clientToken": self.clientToken, "userAuthToken" : userAuthToken, "username":username]).responseJSON { (NSURLRequest, NSHTTPURLResponse, JSON, NSError) in
            
                switch (NSHTTPURLResponse!.statusCode) {

                case 200:
                    let res = JSON as Dictionary<String,AnyObject>
                    
                    self.user = User(json: res, authToken:userAuthToken)
                    
                    let data = NSKeyedArchiver.archivedDataWithRootObject(self.user!)
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: "TimetablerUser")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    self.fetchTimetable()
                    self.loginDelegate?.didFetchUser?()
                    
                default:
                    fatalError("Unknown Error Fetching User")
                    
                }
            }
    }
    
    func fetchTimetable(range:TimetableEventRange = TimetableEventRange.All){
        
        var params:[String : AnyObject] = ["clientToken": self.clientToken, "userAuthToken":self.user!.authToken as String!, "username":self.user!.username as String]
        
        Alamofire.request(.GET, "http://178.62.37.231/api/user/timetable/", parameters:params).responseJSON { (NSURLRequest, NSHTTPURLResponse, JSON, NSError) in
            
            switch (NSHTTPURLResponse!.statusCode) {
                
                case 200:
                    let res = JSON as Array<AnyObject>
                    
                    self.timetable.addEvents(res)
                    self.loginDelegate?.didFetchTimetable?()
                
                default:
                    fatalError("Unknown Error Fetching Timetable")
                
            }
        }
    }
    
    class var sharedInstance: Timetabler {
        struct Static {
            static var instance: Timetabler?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Timetabler()
        }
        
        return Static.instance!
    }
}
