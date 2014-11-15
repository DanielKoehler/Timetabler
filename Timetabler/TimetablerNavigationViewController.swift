//
//  TimetablerNavigationViewController.swift
//  Timetabler
//
//  Created by Daniel Koehler on 29/10/2014.
//  Copyright (c) 2014 DanielKoehler. All rights reserved.
//

import UIKit

class TimetablerNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timetabler = Timetabler.sharedInstance

        if (timetabler.user == nil){
            
            self.pushViewController(LoginViewController(), animated: false)
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
