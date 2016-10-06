//
//  ViewController.swift
//  desire2learn
//
//  Created by John Keller on 10/6/16.
//  Copyright © 2016 John Keller. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.sendRequestRequest()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendRequestRequest() {
        let login = ["Login":"Login", "password":"s%23N!PgZpSPw3H%26mnewTH", "userName":"joke1008"]
        
        let url = NSURL(string: "https://learn.colorado.edu/d2l/lp/auth/login/login.d2l")!
        
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url as URL)
        
        do {
            // JSON all the things
            let auth = "userName=joke1008&Login=Login&password=s%23N%21PgZpSPw3H%26mnewTH"
            
            // Set the request content type to JSON
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("iOS", forHTTPHeaderField: "User-Agent")
            request.addValue("gzip, deflate, sdch, br", forHTTPHeaderField: "Accept-Encoding")
            request.addValue("1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
            
            // The magic...set the HTTP request method to POST
            request.httpMethod = "POST"
            
            // Add the JSON serialized login data to the body
            request.httpBody = auth.data(using: String.Encoding.utf8)
            
            print(request.allHTTPHeaderFields)
            
            
            // Create the task that will send our login request (asynchronously)
            let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                // Do something with the HTTP response
                print("Got response \(response) with error \(error)")
                let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print(strData)
            })
            
            // Start the task on a background thread
            task.resume()
            
            
            
            let request2 = NSMutableURLRequest(url: NSURL(string: "https://learn.colorado.edu/d2l/lp/auth/login/ProcessLoginActions.d2l") as! URL)
            let task2 = session.dataTask(with: request2 as URLRequest, completionHandler: { (data, response, error) -> Void in
                // Do something with the HTTP response
                print("Got response \(response) with error \(error)")
                let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print(strData)
            })
            task2.resume()
            
        } catch {
            // Handle your errors folks...
            print("Error")
        }
    }
    
    func data_request()
    {
        let url:URL = URL(string: "")!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let paramString = "data=Hello"
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                print("error")
                return
            }
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString)
            
        })
        
        task.resume()
        
    }
}

