//
//  LoginViewController.swift
//  Timetabler
//
//  Created by Daniel Koehler on 27/10/2014.
//  Copyright (c) 2014 DanielKoehler. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, TimetablerLoginDelegate {
    
    var timetabler = Timetabler.sharedInstance
    
    var signInButton = UIButton()
    var lostButton = UIButton()
    var totpField = UITextField()
    
    var progressView = UIActivityIndicatorView()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        timetabler.loginDelegate = self
        
        navigationController?.navigationBarHidden = true
        
        setUpBackground()
        setUpLoginPanel()
        setUpCodeEntry()
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated:false)
        

    }
    
    func setUpBackground() {
        
        let gradient : CAGradientLayer = CAGradientLayer()
        gradient.frame =  self.view.frame
        gradient.colors = CGColor.grandientLight()
        view.layer.insertSublayer(gradient, atIndex: 0)
        
    }
    
    func setUpLoginPanel(){
        // Logo
        var logo = Ionicons.labelWithIcon(iconName: Ionicon.Ios7TimeOutline, size:70, color:UIColor.whiteColor());
        logo.center = CGPointMake(view.bounds.width / 2, 150)
        view.addSubview(logo)
        
        var title = UIImageView(image: UIImage(named:"logo"))
        title.sizeToFit()
        title.center = CGPointMake(view.bounds.width / 2, 225)
        view.addSubview(title)
        
    }
    
    func setUpCodeEntry(){
    
        totpField = UITextField(frame:CGRectMake(70, 275, 180, 40))
        totpField.borderStyle = UITextBorderStyle.RoundedRect
        totpField.font = UIFont.systemFontOfSize(15)
        totpField.placeholder = "AB-12-CD-34"
        totpField.text = "RQ-24-TO-08"
        totpField.textAlignment = NSTextAlignment.Center
        totpField.autocorrectionType = UITextAutocorrectionType.No
        totpField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        totpField.keyboardType = UIKeyboardType.ASCIICapable
        totpField.returnKeyType = UIReturnKeyType.Default
        totpField.clearButtonMode = UITextFieldViewMode.WhileEditing
        totpField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        totpField.delegate = self;
        
        signInButton.setTitle("Sign In", forState: UIControlState.Normal)
        signInButton.addTarget(self, action: Selector("signIn"), forControlEvents: UIControlEvents.TouchUpInside)
        signInButton.setTitleColor( UIColor.whiteColor(), forState: UIControlState.Normal)
        signInButton.setTitleColor( UIColor.grayColor(), forState: UIControlState.Highlighted)
        signInButton.sizeToFit()
        signInButton.center = CGPointMake(view.bounds.width / 2, 345)
        
        lostButton.setTitle("Forgot authorisation token?", forState: UIControlState.Normal)
        lostButton.setTitleColor( UIColor.whiteColor(), forState: UIControlState.Normal)
        lostButton.setTitleColor( UIColor.grayColor(), forState: UIControlState.Highlighted)
        lostButton.titleLabel?.font = UIFont.systemFontOfSize(10)
        lostButton.sizeToFit()
        lostButton.center = CGPointMake(view.bounds.width / 2, 385)
        
        view.addSubview(totpField)
        view.addSubview(signInButton)
        view.addSubview(lostButton)
        
    }
    
    func  textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
            
        // All digits entered
        if (range.location == 11) {
            return false;
        }
    
        // Reject appending non-digit characters
        if (range.length == 0 && (!NSCharacterSet.alphanumericCharacterSet().characterIsMember(string.utf16[0]))) {
                return false;
        }
        
        if (range.length == 0 && contains([2,5,8], range.location)) {
                textField.text = NSString(format:"%@-%@", textField.text, string.uppercaseString)
                return false;
        }
        
        // Delete hyphen when deleting its trailing digit.uppercaseString
        if (range.length == 1 && contains([3,6,9], range.location))  {
                var nrange = NSRange(location: range.location, length: range.length)
                nrange.location--
                nrange.length = 2
            
                textField.text = (textField.text as NSString).stringByReplacingCharactersInRange(nrange, withString: "")
            
                return false;
        }
        
        textField.text = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string.uppercaseString)
        
        return false;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.signIn()
        
        return true
        
    }
   
    func signIn(){
        
        timetabler.login(totpField.text.stringByReplacingOccurrencesOfString("-", withString: ""))
        totpField.resignFirstResponder()
        
        progressView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        progressView.sizeToFit()
        progressView.center = signInButton.center
        progressView.startAnimating()
        
        view.addSubview(progressView)
        signInButton.hidden = true
        
    }
    
    func didFetchTimetable() {
        
        self.navigationController?.popViewControllerAnimated(false)
    
    }
    
    func didFetchUser() {
        
    
    }
    
    
    
    func TOTPTokenWasInvalid()
    {
        
        progressView.stopAnimating()
        signInButton.hidden = false
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    
    }
    

}
