//
//  EnrollmentsTableViewController.swift
//  desire2learn
//
//  Created by John Keller on 10/6/16.
//  Copyright © 2016 John Keller. All rights reserved.
//

import UIKit
import Alamofire

class EnrollmentsTableViewController: UITableViewController {

    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    var classList:Array = [Any]()
    var otherList:Array = [Any]()
    var firstName: String = ""
    var lastName: String = ""
    var identifier: String = ""
    
    var userName = ""
    var password = ""
    
    var loggedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let keychain = KeychainSwift()
        keychain.synchronizable = true // Allow this keychain to be synced across devices
        
        if (self.classList.count == 0) && (self.otherList.count == 0) {
            if ((keychain.get("d2lUsername") != nil) && (keychain.get("d2lPassword") != nil)) {
                userName = keychain.get("d2lUsername")!
                password = keychain.get("d2lPassword")!
                
                self.login()
                self.loggedIn = true
                logoutButton.title = "Logout"
                self.loadClasses()
                
            } else {
                print("Error retrieving username and password, displaying login screen")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                self.present(controller, animated: true, completion: nil)
            }
        } else {
            print("all is good!")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let keychain = KeychainSwift()
        keychain.synchronizable = true // Allow this keychain to be synced across devices
        
        super.viewDidAppear(animated)
        if ((keychain.get("d2lUsername") == nil) && (keychain.get("d2lPassword") == nil)) {
            print("Error retrieving username and password, displaying login screen")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(controller, animated: true, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if(otherList.count > 0){
            return 2
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return self.classList.count
        } else {
            return self.otherList.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath)
        
        if(indexPath.section == 0){
            let sub = classList[indexPath.row] as! NSArray
            let name = sub[0] as! NSArray
            let role = sub[1] as! NSArray
            cell.textLabel?.text = name[0] as? String
            cell.detailTextLabel?.text = role[0] as? String
        } else {
            let sub = otherList[indexPath.row] as! NSArray
            let name = sub[0] as! NSArray
            let role = sub[1] as! NSArray
            cell.textLabel?.text = name[0] as? String
            cell.detailTextLabel?.text = role[0] as? String
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0) {
            if classList.count > 0 {
                return "Classes"
            } else {
                return nil
            }
        } else {
            return "Other Enrollments"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? ClassTableViewController {
        let selected = tableView.indexPathForSelectedRow?.row
        if(tableView.indexPathForSelectedRow?.section == 0) {
            let sub = classList[selected!] as! NSArray
            let name = sub[0] as! NSArray
            let role = sub[1] as! NSArray
            vc.class_name = (name[0] as? String)!
            vc.class_id = (role[0] as? NSNumber)!
        } else if(tableView.indexPathForSelectedRow?.section == 1) {
            let sub = otherList[selected!] as! NSArray
            let name = sub[0] as! NSArray
            let role = sub[1] as! NSArray
            vc.class_name = (name[0] as? String)!
            vc.class_id = (role[0] as? NSNumber)!
            }
        }
    }
    

    
    func login() {
        let loginRequest : Dictionary = [
            "Login":"Login",
            "password" : self.password,
            "userName" : self.userName
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
            debugPrint(response.response?.allHeaderFields)
            // Login requires going to the following URL to finish the login process...
            Alamofire.request("https://learn.colorado.edu/d2l/lp/auth/login/ProcessLoginActions.d2l").responseData { response in
                print("Processing login...")
                debugPrint(response)
                
                
                
                if let headerFields = response.response?.allHeaderFields as? [String: String], let URL = response.request?.url {
                    print(URL, headerFields)
                }
                
                Alamofire.request("https://learn.colorado.edu/d2l/api/lp/1.4/users/whoami").responseJSON { response in
                    if let res = response.result.value as? [String: AnyObject] {
                        print("here:::")
                        print(Alamofire.URLSession.shared.configuration.httpCookieStorage?.cookies)
                        
                        if let cookies = Alamofire.URLSession.shared.configuration.httpCookieStorage?.cookies {
                            let cookiesData: NSData = NSKeyedArchiver.archivedData(withRootObject: cookies) as NSData
                            let userAccount = self.userName
                            let domain = "d2l"
                            let keychainQuery: [NSString: NSObject] = [
                                kSecClass: kSecClassGenericPassword,
                                kSecAttrAccount: userAccount as NSObject,
                                kSecAttrService: domain as NSObject,
                                kSecValueData: cookiesData]
                            SecItemDelete(keychainQuery as CFDictionary) //Trying to delete the item from Keychaing just in case it already exists there
                            let status: OSStatus = SecItemAdd(keychainQuery as CFDictionary, nil)
                            if (status == errSecSuccess) {
                                print("Cookies succesfully saved into Keychain for user \(self.userName)")
                            }
                        }
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        print(res)
                        self.title = "D2L: \(res["FirstName"]!) \(res["LastName"]!)"
                        print("Loaded profile \(res["FirstName"]!) \(res["LastName"]!)")
                        self.loadClasses()
                    }
                    
                }
            }
        }

    }
    
    func loadClasses() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request("https://learn.colorado.edu/d2l/api/lp/1.8/enrollments/myenrollments/").responseJSON {  response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                //print(json["Items"])
                for (subJson) in json["Items"].arrayValue {
                    
                    //print(subJson["Access"])
                    if(subJson["OrgUnit"]["Type"]["Name"].string == "Course Offering"){
                        print(subJson)
                        if(subJson["OrgUnit"]["Code"]).stringValue.contains("cmty") {
                            let element:Array = [[subJson["OrgUnit"]["Name"].stringValue],[subJson["OrgUnit"]["Id"].intValue],[subJson["Access"]["CanAccess"].boolValue],[subJson["Access"]["ClasslistRoleName"].stringValue]] as Array
                            print("adding",subJson["OrgUnit"]["Name"].stringValue)
                            self.otherList.append(element)
                        } else {
                            let element:Array = [[subJson["OrgUnit"]["Name"].stringValue],[subJson["OrgUnit"]["Id"].intValue],[subJson["Access"]["CanAccess"].boolValue],[subJson["Access"]["ClasslistRoleName"].stringValue]] as Array
                            print("adding",subJson["OrgUnit"]["Name"].stringValue)
                            self.classList.append(element)
                        }
                    }
                }
                self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                print(self.classList,self.classList.count)
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
            
        }
    }

    @IBAction func logoutButton(_ sender: Any) {
        
        // Remove all the contents that (may) have loaded
        self.classList.removeAll()
        self.otherList.removeAll()
        
        
        let keychain = KeychainSwift()
        keychain.synchronizable = true // Allow this keychain to be synced across devices
        keychain.delete("d2lPassword") // Remove the password from keychain
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.present(controller, animated: true, completion: nil)
    }
}
