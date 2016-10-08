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
    var user_id: String = ""
    var user_role: String = ""
    var news_items: Array = [Any]()
    
    var class_content: Array = [Any]()
    
    var grades: Array = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = class_name
        print(class_id,class_name)
        
        retrieveNews()
        
        retrieveClassContent()
        
        retrieveGrades()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if(section == 0){
            if(self.news_items.count > 3){
                return 3
            } else {
                return self.news_items.count
            }
        } else if(section == 1) {
            return grades.count
        } else {
            return self.class_content.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
        if(indexPath.section == 0){
            let sub = news_items[indexPath.row] as! NSArray
            let name2 = sub[0] as! String
            let date = sub[2] as! String
            let attachments = sub[3] as! NSArray
            
            let formatter = DateFormatter()
            formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date2 = formatter.date(from: date)
            formatter.dateFormat = "M/d"
            let st = formatter.string(from: date2!)

            cell.textLabel?.text = name2
            if attachments.count != 0 {
                cell.detailTextLabel?.text = "📎 "+st
            } else {
                cell.detailTextLabel?.text = st
            }
            
        } else if(indexPath.section == 1){
            let sub = grades[indexPath.row] as! NSArray
            let name2 = sub[0] as! String
            let weight = sub[8] as! NSArray
            cell.textLabel?.text = name2
            cell.detailTextLabel?.text = "\(weight.count)"
        } else {
            let sub = class_content[indexPath.row] as! NSArray
            let name2 = sub[0] as! String
            let count = sub[2] as! NSArray
            cell.textLabel?.text = "📁 "+name2
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row+1)!")
        if indexPath.section == 0 {
            
            let vc = NewDetailViewController()
            let sub = news_items[indexPath.row] as! NSArray
            let code = sub[1] as! JSON
            print(sub)
            vc.html = code.stringValue
            vc.newstitle = sub[0] as! String
            vc.class_id = String(describing: self.class_id)
            vc.article_id = sub[4] as! String
            print(sub[3] as! NSArray)
            vc.attachments.append(contentsOf: sub[3] as! NSArray)
            
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date2 = formatter.date(from: sub[2] as! String)
            formatter.dateStyle = .long
            formatter.timeStyle = .short
            let st = formatter.string(from: date2!)
            vc.details.append("🗓 Published on "+st)
            
            vc.details.append("🔗 "+"https://learn.colorado.edu/d2l/lms/news/main.d2l?ou=\(class_id)")
            self.navigationController?.pushViewController(vc, animated: true)
            //self.present(vc, animated: true, completion: nil)
        } else if(indexPath.section == 1) {
            print("Selected Grade Object")
            let vc = GradeViewController()
            let sub = grades[indexPath.row] as! NSArray
            print(sub)
            
            vc.name = sub[0] as! String
            let fi = sub[sub.count-1] as! NSArray
            vc.grades.append(contentsOf: fi)
            vc.class_id = String(describing: self.class_id)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            print("Selected Grade Object")
            let vc = FileBrowserViewController()
            let sub = class_content[indexPath.row] as! NSArray
            vc.name = sub[0] as! String
            let fi = sub[2] as! NSArray
            vc.files.append(contentsOf: fi)
            vc.class_id = String(describing: self.class_id)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return "news"
        } else if(section == 1){
            return "grades"
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

    
    func retrieveNews(){
        print("Requesting news...")
        Alamofire.request("https://learn.colorado.edu/d2l/api/le/1.5/\(class_id)/news/").responseJSON { response in
            //debugPrint(response)
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                for (subJson) in json.arrayValue {
                    var element:Array = [subJson["Title"].stringValue,subJson["Body"]["Html"],subJson["StartDate"].stringValue] as Array
                    var attachments = [Any]()
                    for item in subJson["Attachments"].arrayValue {
                        var att = [Any]()
                        att.append(item["FileName"].stringValue)
                        att.append(item["Size"].stringValue)
                        att.append(item["FileId"].stringValue)
                        attachments.append(att)
                    }
                    element.append(attachments)
                    element.append(subJson["Id"].stringValue)
                    self.news_items.append(element)
                }
                self.tableView.reloadData()
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
            //self.debugActivity.stopAnimating()
            
        }
    }
    
    func retrieveGrades(){
        print("Requesting grades...")
        Alamofire.request("https://learn.colorado.edu/d2l/api/le/1.5/\(class_id)/grades/categories/").responseJSON { response in
            //debugPrint(response)
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                for (subJson) in json.arrayValue {
                    //print(subJson)
                    var sub_arr = [Any]()
                    sub_arr.append(subJson["Name"].stringValue)
                    sub_arr.append(subJson["MaxPoints"].stringValue)
                    sub_arr.append(subJson["Id"].stringValue)
                    sub_arr.append(subJson["NumberOfLowestToDrop"].intValue)
                    sub_arr.append(subJson["NumberOfHighestToDrop"].intValue)
                    sub_arr.append(subJson["Weight"].stringValue)
                    sub_arr.append(subJson["MaxPoints"].stringValue)
                    sub_arr.append(subJson["WeightDistributionType"].stringValue)
                    var sub_grades = [Any]()
                    for (subsub) in subJson["Grades"].arrayValue {
                        //print(subsub)
                        var sub_sub = [Any]()
                        sub_sub.append(subsub["Name"].stringValue)
                        sub_sub.append(subsub["Id"].stringValue)
                        sub_sub.append(subsub["MaxPoints"].stringValue)
                        sub_sub.append(subsub["Weight"].stringValue)
                        sub_grades.append(sub_sub)
                    }
                    sub_arr.append(sub_grades)
                    self.grades.append(sub_arr as Array)
                }
                self.tableView.reloadData()
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
            //self.debugActivity.stopAnimating()
            
        }
//        Alamofire.request("https://learn.colorado.edu/d2l/api/le/1.5/\(class_id)/grades/").responseJSON { response in
//            //debugPrint(response)
//            switch response.result {
//            case .success(let data):
//                let json = JSON(data)
//                for (subJson) in json.arrayValue {
//                    //print(subJson)
//                    var sub_arr = [Any]()
//                    sub_arr.append(subJson["Name"].stringValue)
//                    sub_arr.append(subJson["Id"].stringValue)
//                    sub_arr.append(subJson["CategoryId"].stringValue)
//                    sub_arr.append(subJson["GradeSchemeUrl"].stringValue)
//                    sub_arr.append(subJson["MaxPoints"].stringValue)
//                    sub_arr.append(subJson["Weight"].stringValue)
//                    self.grades.append(sub_arr as Array)
//                }
//            case .failure(let error):
//                print("Request failed with error: \(error)")
//            }
//            //self.debugActivity.stopAnimating()
//            
//        }
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
