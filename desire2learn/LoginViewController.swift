//
//  LoginViewController.swift
//  desire2learn
//
//  Created by John Keller on 11/1/16.
//  Copyright © 2016 John Keller. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var onepasswordButton: UIButton!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keychain = KeychainSwift()
        keychain.synchronizable = true // Allow this keychain to be synced across devices
        
        if ((keychain.get("d2lUsername") != nil) && (keychain.get("d2lPassword") != nil)) {
            self.usernameField.text = keychain.get("d2lUsername")!
            self.passwordField.text = keychain.get("d2lPassword")!
        }
        
        self.usernameField.becomeFirstResponder();
        
        //self.usernameField.focus = true
        self.passwordField.isSecureTextEntry = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if OnePasswordExtension.shared().isAppExtensionAvailable() == false {
            self.onepasswordButton.isHidden = true
        } else {
            self.onepasswordButton.isHidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LoginPressed(_ sender: Any) {

        if ((passwordField.text?.characters.count)! > 3 && (usernameField.text?.characters.count)! > 3) {
            // TODO: test login
            let usr = usernameField.text
            let pass = passwordField.text
            
            var sucess:Bool = false
            
            let help = D2LFunctions()
            help.login(username: usr!, password: pass!, completion: {
                (res: NSDictionary?) in
                if ((res?.allValues.count)! > 0) {
                    sucess = true;
                    
                    print("Saving login information to Keychain");
                    
                    let keychain = KeychainSwift()
                    keychain.synchronizable = true // Allow this keychain to be synced across devices
                    keychain.set(usr!, forKey: "d2lUsername")
                    keychain.set(pass!, forKey: "d2lPassword")
                    
                    print("Returning to main d2l view")
                    self.dismiss(animated: true, completion: nil)
                    
                }
                
            })

        } else {
            print("Error: Fields not filled in")
        }
        
        
    }
    
    @IBAction func findLoginFrom1Password(sender:AnyObject) -> Void {
        OnePasswordExtension.shared().findLogin(forURLString: "https://colorado.edu", for: self, sender: sender, completion: { (loginDictionary, error) -> Void in
            if loginDictionary == nil {
                if ((error?.localizedDescription) != nil) {
                    print("Error: \(error?.localizedDescription)")
                }
                return
            }
            
            self.usernameField.text = loginDictionary?[AppExtensionUsernameKey] as? String
            self.passwordField.text = loginDictionary?[AppExtensionPasswordKey] as? String

        })
    }

}
