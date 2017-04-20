//
//  ViewController.swift
//  desire2learn
//
//  Created by John Keller on 10/6/16.
//  Copyright © 2016 John Keller. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    
    var logo = UIImageView()
    var bgimage = UIImageView()
    
    var debugActivity = UIActivityIndicatorView()
    var password = UITextField()
    var username = UITextField()

    var loginButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo = UIImageView(frame: CGRect(x: 30, y: 40, width: self.view.frame.width - 60, height: 80))
        bgimage = UIImageView(frame: self.view.frame)
        
        username = UITextField(frame: CGRect(x: 10, y: 150, width: self.view.frame.width - 20, height: 37))
        password = UITextField(frame: CGRect(x: 10, y: 200, width: self.view.frame.width - 20, height: 37))
        debugActivity = UIActivityIndicatorView(frame: CGRect(x: 10, y: 300, width: self.view.frame.width - 20, height: 20))
        
        loginButton = UIButton(frame:  CGRect(x: 10, y: 280, width: self.view.frame.width - 20, height: 20))
        
        self.debugActivity.isHidden = true
        self.password.isSecureTextEntry = true
        
        self.username.text = "joke1008"
        self.username.keyboardAppearance = .dark
        self.username.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        self.username.borderStyle = .roundedRect
        self.password.text = "s#N!PgZpSPw3H&mnewTH"
        self.password.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        self.password.keyboardAppearance = .dark
        self.password.borderStyle = .roundedRect
        
        self.loginButton.setTitle("Login", for: .normal)
        
        self.debugActivity.isHidden = true
        self.username.isEnabled = true
        self.password.isEnabled = true
        self.loginButton.isHidden = false
        self.loginButton.addTarget(self, action: #selector(login(_:)), for: UIControlEvents.allTouchEvents)
        
        logo.image = UIImage(named: "culogo.png")
        logo.contentMode = .scaleAspectFit
        
        bgimage.image = UIImage(named: "boulder.jpg")
        bgimage.contentMode = .scaleAspectFill
        
        self.view.addSubview(bgimage)
        self.view.addSubview(logo)
        self.view.addSubview(username)
        self.view.addSubview(password)
        self.view.addSubview(debugActivity)
        self.view.addSubview(loginButton)
        
        if(((self.username.text?.characters.count)!>3) && ((self.password.text?.characters.count)!>3)){
            //self.login(self)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func login(_ sender: AnyObject) {
//        self.debugActivity.isHidden = false
//        self.loginButton.isHidden = true
//        
//        self.username.isEnabled = false
//        self.password.isEnabled = false
//        
//        self.sendRequestRequest()
        print("Login button pressed")
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func resetView() {
        self.debugActivity.isHidden = true
        self.loginButton.isHidden = false

        self.username.isEnabled = true
        self.password.isEnabled = true
        self.view.backgroundColor = UIColor.white
    }
    
    func sendRequestRequest() {
        guard self.username.text != nil else {
            print("ooops")
            return
        }
        guard self.password.text != nil else {
            print("ooops")
            return
        }
        
        print("login pressed")
        
        

    }
}

