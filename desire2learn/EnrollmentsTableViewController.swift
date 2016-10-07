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

    var classList:Array = [Any]()
    var otherList:Array = [Any]()
    var firstName: String = ""
    var lastName: String = ""
    var identifier: String = ""
    var loggedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(loggedIn == false) {
            login()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
            return "Current Classes"
        } else {
            return "Other Enrollments"
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ClassTableViewController {
        let selected = tableView.indexPathForSelectedRow?.row
        if(tableView.indexPathForSelectedRow?.section == 0) {
            let sub = classList[selected!] as! NSArray
            let name = sub[0] as! NSArray
            let role = sub[1] as! NSArray
            vc.class_name = (name[0] as? String)!
            vc.class_id = (role[0] as? NSNumber)!
        } else if(tableView.indexPathForSelectedRow?.section == 0) {
            let sub = otherList[selected!] as! NSArray
            let name = sub[0] as! NSArray
            let role = sub[1] as! NSArray
            vc.class_name = (name[0] as? String)!
            vc.class_id = (role[0] as? NSNumber)!
            }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        }
    }
    

    
    func login() {
        let loginRequest : Dictionary = [
            "Login":"Login",
            "password" : "s#N!PgZpSPw3H&mnewTH",
            "userName" : "joke1008"
        ]
        
        
        
        let serverUrl = "https://learn.colorado.edu/d2l/lp/auth/login/login.d2l"
        // Both calls are equivalent
        Alamofire.request(serverUrl, method: .post, parameters: loginRequest).responseData { response in
            print(loginRequest)
            debugPrint(response)
            let res_url:String = (response.response!.url?.absoluteString)!
            if(res_url.range(of: "BAD_CREDENTIALS") != nil) {
                print("Error logging in...")
                return
            }
            //self.progress.text = "Processing login..."
            Alamofire.request("https://learn.colorado.edu/d2l/lp/auth/login/ProcessLoginActions.d2l").responseData { response in
                print("Processing login...")
                debugPrint(response)
                //self.progress.text = "Loading profile information..."
                Alamofire.request("https://learn.colorado.edu/d2l/api/lp/1.4/users/whoami").responseJSON { response in
                    //debugPrint(response)
                    if let res = response.result.value as? [String: AnyObject] {
                        print(res)
                        self.navigationController?.title = "\(res["FirstName"]!) \(res["LastName"]!)"
                        print("Loaded \(res["FirstName"]!) \(res["LastName"]!)")
                        self.loadClasses()
                    }
                    //self.debugActivity.stopAnimating()
                    
                }
            }
        }

    }
    
    func loadClasses() {
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
                
                print(self.classList,self.classList.count)
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
            
        }
    }

}
