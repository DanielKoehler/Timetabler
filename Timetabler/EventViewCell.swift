//
//  EventViewCell.swift
//  Timetabler
//
//  Created by Daniel Koehler on 31/10/2014.
//  Copyright (c) 2014 DanielKoehler. All rights reserved.
//

import UIKit
//import Ionicons

class EventViewCell: UICollectionViewCell {
    
    @IBOutlet weak var active: UIButton!
    @IBOutlet weak var moduleTitle: UILabel!
    @IBOutlet weak var moduleSubtitle: UILabel!
    
    var event:TTEvent?
    var contextualIndex:Int?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func setEvent(event:TTEvent)
    {
        // Initialization code
        self.event = event
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "ha"
        moduleTitle.text = "\(event.module.id) - \(event.shortLocation())"
        moduleSubtitle.text = event.module.title.uppercaseString
        
        active.addTarget(self, action: Selector("changeActiveState:"), forControlEvents:UIControlEvents.TouchUpInside)

    }
    
    func changeActiveState(sender:UIButton) {
        
        if sender.selected == true {
            active.selected = false
        } else {
            active.selected = true
        }
        
    }
}
