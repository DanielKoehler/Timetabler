//
//  TimetablerStructures.swift
//  Timetabler
//
//  Created by Daniel Koehler on 31/10/2014.
//  Copyright (c) 2014 DanielKoehler. All rights reserved.
//

import Foundation

class TTModule {
    var id: String
    var title: String
    init (id:String, title:String){
        self.id = id
        self.title = title
    }
    
//    required init(coder decoder: NSCoder){
//        
//        self.id = decoder.decodeObjectForKey("id") as String
//        self.title = decoder.decodeObjectForKey("title") as String
//        
//    }
//    
//    func encodeWithCoder(encoder: NSCoder){
//        
//        encoder.encodeObject(self.id, forKey: "id")
//        encoder.encodeObject(self.title, forKey: "title")
//        
//    }
}

class TTEvent {
    
    var oid: String
    var end: NSDate
    var start: NSDate
    var location:[String]
    var module: TTModule
    var status: String
    var summary: String
    
    var events: [TTEvent]?
    
    init(json:NSDictionary) {
        
        self.oid = json.objectForKey("_id") as String
        self.end = NSDate(timeIntervalSince1970: Double(((json.objectForKey("end") as NSDictionary).objectForKey("$date") as NSNumber)) / 1000)
        self.start = NSDate(timeIntervalSince1970: Double(((json.objectForKey("start") as NSDictionary).objectForKey("$date") as NSNumber)) / 1000)
        self.location = json.objectForKey("location") as [String]
        
        let module = json["module"] as Dictionary<String,String>
        
        self.module = TTModule(id: module["id"]!, title: module["title"]!)
        self.status = json.objectForKey("status") as String
        self.summary = json.objectForKey("summary") as String
        
    }
    
    
    func shortLocation() -> String {
        
        let l = location[0].componentsSeparatedByString("/")
        
        if l.count > 2 {
            
            return "\(l[1])/\(l[2])"
            
        } else if (strlen(l[0]) > 3 && l.count == 2) {
            
            return "\((l[0] as NSString).substringToIndex(1))/\(l[1])"
            
        } else {
            
            return l[0]
        
        }
    }
}

class User: NSObject, NSCoding {
    
    var oid: String
    var comscEmailAddress: String
    var created: NSDate
    var courseDescription: String
    var firstName: String
    var lastName: String
    var middleInitals: String
    var username: String
    var webcal: String
    var authToken: String
    var active: Bool = true
    
    init(json:NSDictionary, authToken: String) {
        
        self.authToken = authToken
        self.oid = (json.objectForKey("_id") as NSDictionary).objectForKey("$oid") as String
        self.comscEmailAddress = json.objectForKey("comscEmailAddress") as String
        self.created =  NSDate(timeIntervalSince1970: Double(((json.objectForKey("created") as NSDictionary).objectForKey("$date") as NSNumber)) / 1000)
        self.courseDescription = json.objectForKey("description") as String
        self.firstName = json.objectForKey("firstName") as String
        self.lastName = json.objectForKey("lastName") as String
        self.middleInitals = json.objectForKey("middleInitals") as String
        self.username = json.objectForKey("username") as String
        self.webcal = json.objectForKey("webcal") as String
        
    }
    
    required init(coder decoder: NSCoder){
        
        self.oid = decoder.decodeObjectForKey("oid") as String
        self.authToken = decoder.decodeObjectForKey("authToken") as String
        self.comscEmailAddress = decoder.decodeObjectForKey("comscEmailAddress") as String
        self.created = decoder.decodeObjectForKey("created") as NSDate
        self.courseDescription = decoder.decodeObjectForKey("courseDescription") as String
        self.firstName = decoder.decodeObjectForKey("firstName") as String
        self.lastName = decoder.decodeObjectForKey("lastName") as String
        self.middleInitals = decoder.decodeObjectForKey("middleInitals") as String
        self.username = decoder.decodeObjectForKey("username") as String
        self.webcal = decoder.decodeObjectForKey("webcal") as String
    }
    
    func encodeWithCoder(encoder: NSCoder){
        
        encoder.encodeObject(self.oid, forKey: "oid")
        encoder.encodeObject(self.authToken, forKey: "authToken")
        encoder.encodeObject(self.comscEmailAddress, forKey: "comscEmailAddress")
        encoder.encodeObject(self.created, forKey: "created")
        encoder.encodeObject(self.courseDescription, forKey: "courseDescription")
        encoder.encodeObject(self.firstName, forKey: "firstName")
        encoder.encodeObject(self.lastName, forKey: "lastName")
        encoder.encodeObject(self.middleInitals, forKey: "middleInitals")
        encoder.encodeObject(self.username, forKey: "username")
        encoder.encodeObject(self.webcal, forKey: "webcal")
    
    }
    
}
