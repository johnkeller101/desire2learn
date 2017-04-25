//
//  FileAttachmentViewController.swift
//  desire2learn
//
//  Created by John Keller on 10/8/16.
//  Copyright © 2016 John Keller. All rights reserved.
//

import UIKit
import WebKit

class FileAttachmentViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var url: String = ""
    var name: String = ""
    var webView: WKWebView?
    
    override func loadView() {
        super.loadView()
        self.webView = WKWebView(frame: self.view.bounds)
        self.webView?.navigationDelegate = self
        self.webView?.uiDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = name
        
        
        let btn1 = UIButton(type: .system)
        btn1.setImage(UIImage(named: "Share"), for: .normal)
        btn1.tintColor = .blue
        btn1.frame = CGRect(x: 0, y: 0, width: 18, height: 25)
        btn1.addTarget(self, action: #selector(FileAttachmentViewController.shareButton), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)

        self.navigationItem.setRightBarButton(item1, animated: false)
        
        
        var cookiescript:[HTTPCookie] = [HTTPCookie()]
        
        
        let keychain = KeychainSwift()
        keychain.synchronizable = true // Allow this keychain to be synced across devices
        
        let userAccount = keychain.get("d2lUsername")!
        let domain = "d2l"
        let keychainQueryForCookies: [NSString: NSObject] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: domain as NSObject, // we use JIRA URL as service string for Keychain
            kSecAttrAccount: userAccount as NSObject,
            kSecReturnData: kCFBooleanTrue,
            kSecMatchLimit: kSecMatchLimitOne]
        var rawResultForCookies: AnyObject?
        let status: OSStatus = SecItemCopyMatching(keychainQueryForCookies as CFDictionary, &rawResultForCookies)
        if (status == errSecSuccess) {
            let retrievedData = rawResultForCookies as? NSData
            if let unwrappedData = retrievedData {
                if let cookies = NSKeyedUnarchiver.unarchiveObject(with: unwrappedData as Data) as? [HTTPCookie] {
                    // Add cookies to request
                    cookiescript = cookies
                    //request.addValue(script, forHTTPHeaderField: "Cookie")
                }
            }
        }  
        self.webView?.sizeToFit()

        var request = URLRequest(url: URL(string: url)!)
        
        let values = HTTPCookie.requestHeaderFields(with: cookiescript)
        request.allHTTPHeaderFields = values
        
        self.webView?.load(request)
        
        //self.webView?.load(request)

        self.view.addSubview(self.webView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("FAILED")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("FAILED prov")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("LOADING")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("FINISHED")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    ///Generates script to create given cookies
    public func getJSCookiesString(cookies: [HTTPCookie]) -> String {
        var result = ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
        
        for cookie in cookies {
            result += "document.cookie='\(cookie.name)=\(cookie.value); domain=\(cookie.domain); path=\(cookie.path); "
            if let date = cookie.expiresDate {
                result += "expires=\(dateFormatter.string(from: date)); "
            }
            if (cookie.isSecure) {
                result += "secure; "
            }
            result += "'; "
        }
        print(result)
        return result
    }
    
    @IBAction func shareButton(_ sender: Any) {
        
        // Remove all the contents that (may) have loaded
        
        print("testing simplty testing")

    }
}
