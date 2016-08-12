//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by felix on 8/11/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var debugInfoLabel: UILabel!
    
    var originalViewY: CGFloat = 0.0
    var keyboardToMove: CGFloat = 0.0
    var udacityCity: UdacityClient!
    
    @IBAction func login(sender: UIButton) {
        udacityCity.login(usernameTextField.text!, password: passwordTextField.text!) { (result, error) in
            
            if error == nil {
                self.performSegueWithIdentifier("showTabView", sender: self)
            } else {
                print("Login failed: \(error)")
            }
        }
    }
    
    @IBAction func signUp(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalViewY = self.view.frame.origin.y
        
        udacityCity = UdacityClient()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        udacityCity.logoff { (result, error) in
            print("Logoff failed: \(error)")
        }

    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        if isEditingTextFieldWouldBeCoveredByKeyboard(notification) {
            adjustViewToFitKeyboard(notification, offset: keyboardToMove * (-1))
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        adjustViewToFitKeyboard(notification, offset: originalViewY)
    }
    
    func adjustViewToFitKeyboard(notification:NSNotification, offset: CGFloat) {
        var userInfo = notification.userInfo!
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        UIView.animateWithDuration(animationDurarion, animations: { () -> Void in
            self.view.frame.origin.y = offset
        } )
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func isEditingTextFieldWouldBeCoveredByKeyboard(notification: NSNotification) -> Bool{
        var result = false
        if let userInfo = notification.userInfo,
            keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            
            // if the editing textfield would be covered
            for textfield in [ usernameTextField, passwordTextField] {
                if textfield.editing && keyboardSize.CGRectValue().intersects(textfield.frame) {
                    keyboardToMove = textfield.frame.origin.y - textfield.frame.height
                    result = true
                }
            }
        }
        return result
    }
    
}