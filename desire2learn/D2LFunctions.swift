//
//  D2LFunctions.swift
//  desire2learn
//
//  Created by John Keller on 10/28/16.
//  Copyright © 2016 John Keller. All rights reserved.
//

import UIKit
import Alamofire

class D2LFunctions: NSObject {
    
    typealias apiSuccess = (_ result: NSDictionary?) -> Void
    typealias apiProgress = (_ result: NSDictionary?) -> Void // when you want to download or upload using Alamofire..
    typealias apiFailure = (_ error: NSDictionary?) -> Void
    
    func login(username: String, password: String, completion: @escaping (_ information: NSDictionary?) -> Void) {
        pLogin(username: username, password: password) {
            information in
            print(information as Any)
            completion(information)
        }
    }
    
    func pLogin(username: String, password: String, completion: @escaping (_ id: NSDictionary?) -> Void) {
        let loginRequest : Dictionary = [
            "Login":"Login",
            "password" : password,
            "userName" : username
        ]
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        
        
        
        
        let serverUrl = "https://learn.colorado.edu/d2l/lp/auth/login/login.d2l"
        Alamofire.request(serverUrl, method: .post, parameters: loginRequest).responseData { response in
            //debugPrint(response)
            
            let res_url:String = (response.response!.url?.absoluteString)!
            
            if(res_url.range(of: "BAD_CREDENTIALS") != nil) {
                // User has entered an invalid login
                print("Error logging in...")
                // TODO: Add invalid login alert
                return
            }
            //debugPrint(response.response?.allHeaderFields)
            // Login requires going to the following URL to finish the login process...
            Alamofire.request("https://learn.colorado.edu/d2l/lp/auth/login/ProcessLoginActions.d2l").responseData { response in
                print("Processing login...")
                debugPrint(response)
                
                
                
                if let headerFields = response.response?.allHeaderFields as? [String: String], let URL = response.request?.url {
                    print(URL, headerFields)
                }
                
                Alamofire.request("https://learn.colorado.edu/d2l/api/lp/1.4/users/whoami").responseJSON { response in
                    if let res = response.result.value as? [String: AnyObject] {
                        //print("here:::")
                        //print(Alamofire.URLSession.shared.configuration.httpCookieStorage?.cookies)
                        
                        if let cookies = Alamofire.URLSession.shared.configuration.httpCookieStorage?.cookies {
                            let cookiesData: NSData = NSKeyedArchiver.archivedData(withRootObject: cookies) as NSData
                            let userAccount = username
                            let domain = "d2l"
                            let keychainQuery: [NSString: NSObject] = [
                                kSecClass: kSecClassGenericPassword,
                                kSecAttrAccount: userAccount as NSObject,
                                kSecAttrService: domain as NSObject,
                                kSecValueData: cookiesData]
                            SecItemDelete(keychainQuery as CFDictionary) //Trying to delete the item from Keychaing just in case it already exists there
                            let status: OSStatus = SecItemAdd(keychainQuery as CFDictionary, nil)
                            if (status == errSecSuccess) {
                                print("Cookies succesfully saved into Keychain for user \(username)")
                            }
                        }
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        print(res)
                        completion(res as NSDictionary)
                    }
                    
                }
            }
        }
        
        print("all done!")

    }
    
}
