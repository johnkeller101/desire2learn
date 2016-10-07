//
//  ClassTableViewController.swift
//  desire2learn
//
//  Created by John Keller on 10/6/16.
//  Copyright © 2016 John Keller. All rights reserved.
//

import UIKit
import Alamofire

class ClassTableViewController: UITableViewController {
    
    var class_id: NSNumber = 0
    var class_name: String = ""
    var user_role: String = ""
    var news_items: Array = [Any]()
    
    var class_content: Array = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = class_name
        print(class_id,class_name)
        
        retrieveNews()
        
        retrieveClassContent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if(section == 0){
            if(self.news_items.count > 3){
                return 3
            } else {
                return self.news_items.count
            }
        } else {
            return self.class_content.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
        if(indexPath.section == 0){
            let sub = news_items[indexPath.row] as! NSArray
            let name2 = sub[0] as! String
            cell.textLabel?.text = name2
        } else {
            let sub = class_content[indexPath.row] as! NSArray
            let name2 = sub[0] as! String
            cell.textLabel?.text = name2
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return "news"
        } else {
            return "files"
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
        if let vc = segue.destination as? NewDetailViewController {
            //let selected = tableView.indexPathForSelectedRow?.row
            if(tableView.indexPathForSelectedRow?.section == 0) {
                let sub = news_items[(tableView.indexPathForSelectedRow?.row)!] as! NSArray
                print(sub)
                let name = sub[1] as! JSON
                //print()
                vc.html = name.stringValue
                //vc.webView.loadHTMLString(name.stringValue, baseURL: nil)
            }
        }
    }
    
    
    func retrieveNews(){
        print("Requesting news...")
        Alamofire.request("https://learn.colorado.edu/d2l/api/le/1.5/\(class_id)/news/").responseJSON { response in
            //debugPrint(response)
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                for (subJson) in json.arrayValue {
                    print()
                    let element:Array = [subJson["Title"].stringValue,subJson["Body"]["Html"],subJson["StartDate"].stringValue,subJson["Attachments"].stringValue] as Array
                    print("adding",subJson["Title"].stringValue)
                    self.news_items.append(element)
                }
                self.tableView.reloadData()
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
            //self.debugActivity.stopAnimating()
            
        }
    }
    
    func retrieveClassContent(){
        print("Requesting content...")
        Alamofire.request("https://learn.colorado.edu/d2l/api/le/1.5/\(class_id)/content/root/").responseJSON { response in
            //debugPrint(response)
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                for (subJson) in json.arrayValue {
                    //print(subJson)
                    print(subJson["Title"])
                    var content_arr = [Any]()
                    for (subsub) in subJson["Structure"].arrayValue {
                        var sub_arr = [Any]()
                        sub_arr.append(subsub["Title"].stringValue)
                        sub_arr.append(subsub["Type"].stringValue)
                        sub_arr.append(subsub["Id"].stringValue)
                        content_arr.append(sub_arr)
                    }
                    
                    print(content_arr)
                    
                    let element:Array = [subJson["Title"].stringValue,subJson["Id"],content_arr] as Array
                    print("adding",subJson["Title"].stringValue)
                    self.class_content.append(element)
                }
                self.tableView.reloadData()
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
            //self.debugActivity.stopAnimating()
            
        }
    }

}
