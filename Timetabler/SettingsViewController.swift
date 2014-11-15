//
//  SettingsViewController.swift
//  Timetabler
//
//  Created by Daniel Koehler on 02/11/2014.
//  Copyright (c) 2014 DanielKoehler. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var table: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0.353, green: 0.784, blue: 0.984, alpha: 1)
        self.navigationItem.title = "Settings"
        
        self.table = UITableView(frame:CGRectMake(0,0, self.view.frame.width, self.view.frame.height))
        self.view.addSubview(table!)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return UITableViewCell()
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
  
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    
}