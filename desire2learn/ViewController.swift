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

    @IBOutlet weak var debugActivity: UIActivityIndicatorView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var progress: UILabel!

    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.debugActivity.isHidden = true
        self.debugActivity.hidesWhenStopped = true
        self.password.isSecureTextEntry = true
        
        self.username.text = "joke1008"
        self.username.keyboardAppearance = .dark
        self.password.text = "s#N!PgZpSPw3H&mnewTH"
        self.password.keyboardAppearance = .dark
        // Do any additional setup after loading the view, typically from a nib.
       // self.sendRequestRequest()
        if(((self.username.text?.characters.count)!>3) && ((self.password.text?.characters.count)!>3)){
            self.login(self)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func login(_ sender: AnyObject) {
        self.debugActivity.isHidden = false
        self.loginButton.isHidden = true
        
        self.progress.isHidden = false
        self.progress.text = "Logging in as \(self.username.text!)..."
        self.username.isEnabled = false
        self.password.isEnabled = false
        
        self.sendRequestRequest()
    }
    
    func resetView() {
        self.debugActivity.isHidden = true
        self.loginButton.isHidden = false
        
        self.progress.isHidden = false
        self.username.isEnabled = true
        self.password.isEnabled = true
        self.view.backgroundColor = UIColor.white
    }
    
    func sendRequestRequest() {
        guard let uname = self.username.text else {
            print("ooops")
            return
        }
        guard let pword = self.password.text else {
            print("ooops")
            return
        }
        
        let loginRequest : Dictionary = [
            "Login":"Login",
            "password" : pword,
            "userName" : uname
        ]
        
        
        
        let serverUrl = "https://learn.colorado.edu/d2l/lp/auth/login/login.d2l"
        self.debugActivity.startAnimating()
        // Both calls are equivalent
        Alamofire.request(serverUrl, method: .post, parameters: loginRequest).responseData { response in
            print(loginRequest)
            debugPrint(response)
            let res_url:String = (response.response!.url?.absoluteString)!
            if(res_url.range(of: "BAD_CREDENTIALS") != nil) {
                print("Error logging in...")
                self.progress.text = "Error: Invalid credentials"
                self.debugActivity.stopAnimating()
                self.resetView()
                return
            }
            self.progress.text = "Processing login..."
            Alamofire.request("https://learn.colorado.edu/d2l/lp/auth/login/ProcessLoginActions.d2l").responseData { response in
                print("Processing login...")
                debugPrint(response)
                self.progress.text = "Loading profile information..."
                Alamofire.request("https://learn.colorado.edu/d2l/api/lp/1.4/users/whoami").responseJSON { response in
                    //debugPrint(response)
                    if let res = response.result.value as? [String: AnyObject] {
                        print(res)
                        self.progress.text = "Loaded \(res["FirstName"]!) \(res["LastName"]!)"
                    }
                    self.debugActivity.stopAnimating()
                    
                }
            }
            
        }
        
        //HTTPCookieStorage.shared.setCookie(getCookie())
        
        

    }
    
    func setCookie (cookie:HTTPCookie)
    {
        UserDefaults.standard.set(cookie.properties, forKey: "kCookie")
        UserDefaults.standard.synchronize()
    }
    
    func getCookie () -> HTTPCookie
    {
        let cookie = HTTPCookie(properties: UserDefaults.standard.object(forKey: "kCookie") as! [HTTPCookiePropertyKey : Any])
        return cookie!
    }
}

