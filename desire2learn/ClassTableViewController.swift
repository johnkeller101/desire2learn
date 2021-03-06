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
    
    var categories = [String:Any]()
    var gradeobjects = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = class_name
        print(class_id,class_name)
        
        retrieveNews()
        
        retrieveClassContent()
        
        retrieveGrades()
        
        betterGrades()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            // Limit how many news items to display to 3
            if(self.news_items.count > 3){
                return 3
            } else {
                return self.news_items.count
            }
        } else if(section == 1) {
            if (grades.count > 0) && (categories.count > 0) {
                return categories.count
            } else {
                return 0
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
            let date = sub[2] as! String
            let attachments = sub[3] as! NSArray
            
            let formatter = DateFormatter()
            formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date2 = formatter.date(from: date)
            formatter.dateFormat = "M/d"
            let st = formatter.string(from: date2!)

            
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
            cell.textLabel?.text = name2
            if attachments.count != 0 {
                cell.detailTextLabel?.text = "📎 "+st
            } else {
                cell.detailTextLabel?.text = st
            }
            
        } else if(indexPath.section == 1){
            let sub = grades[indexPath.row] as! NSArray
            let name2 = sub[0] as! String
            let arr:NSArray = categories[sub[2] as! String] as! NSArray
            cell.textLabel?.text = name2
            cell.detailTextLabel?.text = (arr[7] as? String)?.replacingOccurrences(of: " ", with: "")
        } else {
            let sub = class_content[indexPath.row] as! NSArray
            let name2 = sub[0] as! String
            cell.textLabel?.text = "📁 "+name2
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        let headerHeight:CGFloat = 25
//        switch section {
//        case 0:
//            if self.news_items.count > 0 {
//                return headerHeight
//            } else {
//                return headerHeight
//            }
//        case 1:
//            if self.grades.count > 0 {
//                return headerHeight
//            } else {
//                return 1
//            }
//        case 2:
//            if self.class_content.count > 0 {
//                return headerHeight
//            } else {
//                return 1
//            }
//        default:
//            return headerHeight
//        }
//    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
        let titleLabel = UILabel(frame: CGRect(x: 15, y: 10, width: (self.view.frame.size.width/3)*2, height: 13))
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)
        var title:String = ""
        if self.news_items.count > 0 && section == 0 {
            title = "news"
        } else if self.grades.count > 0 && section == 1 {
            title = "grades"
        } else if self.class_content.count > 0 && section == 2 {
            title = "files"
        }
        titleLabel.text = title.uppercased()
        titleLabel.textColor = UIColor.darkGray
        
        view.addSubview(titleLabel)
        return view
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
            vc.gradeobjects = self.gradeobjects
            let arr:NSArray = categories[sub[2] as! String] as! NSArray
            vc.catinfo.append(contentsOf: arr)
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerHeight:CGFloat = 30
        
        switch section {
        case 0:
            if self.news_items.count > 0 {
                return headerHeight
            } else {
                return 0
            }
        case 1:
            if self.grades.count > 0 {
                return headerHeight
            } else {
                return 0
            }
        case 2:
            if self.class_content.count > 0 {
                return headerHeight
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if self.news_items.count > 0 {
                return "news"
            } else {
                return nil
            }
        case 1:
            if self.grades.count > 0 {
                return "grades"
            } else {
                return nil
            }
        case 2:
            if self.class_content.count > 0 {
                return "files"
            } else {
                return nil
            }
        default:
            return nil
        }
    }

    
    func retrieveNews(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
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
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
            //self.debugActivity.stopAnimating()
            
        }
    }
    
    func retrieveGrades(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        print("Requesting grades...")
        Alamofire.request("https://learn.colorado.edu/d2l/api/le/1.5/\(class_id)/grades/categories/").responseJSON { response in
            //debugPrint(response)
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                for (subJson) in json.arrayValue {
                    print("GRADES")
                    print(subJson)
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
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
            //self.debugActivity.stopAnimating()
            
        }
    }
    
    func betterGrades() {
        //https://learn.colorado.edu/d2l/api/le/1.5/172556/grades/values/myGradeValues/
        
        Alamofire.request("https://learn.colorado.edu/d2l/api/le/1.5/\(class_id)/grades/values/myGradeValues/").responseJSON { response in
                        switch response.result {
                        case .success(let data):
                            let json = JSON(data)
                            
                            for (subJson) in json.arrayValue {
                                //print(subJson)
                                //var sub_arr = [Any]()
                                if subJson["GradeObjectTypeName"].stringValue == "Category" {
                                    var subsub = [Any]()
                                    subsub.append(subJson["GradeObjectName"].stringValue)
                                    subsub.append(subJson["PointsNumerator"].intValue)
                                    subsub.append(subJson["PrivateComments"].arrayValue)
                                    subsub.append(subJson["GradeObjectIdentifier"].intValue)
                                    subsub.append(subJson["GradeObjectTypeName"].stringValue)
                                    subsub.append(subJson["PointsDenominator"].intValue)
                                    subsub.append(subJson["WeightedDenominator"].intValue)
                                    subsub.append(subJson["DisplayedGrade"].stringValue)
                                    subsub.append(subJson["Comments"].arrayValue)
                                    subsub.append(subJson["GradeObjectType"].stringValue)
                                    subsub.append(subJson["WeightedNumerator"].intValue)
                                    self.categories.updateValue(subsub, forKey: subJson["GradeObjectIdentifier"].stringValue)
                                } else {
                                    var subsub = [Any]()
                                    subsub.append(subJson["GradeObjectName"].stringValue)
                                    subsub.append(subJson["PointsNumerator"].intValue)
                                    subsub.append(subJson["PrivateComments"].arrayValue)
                                    subsub.append(subJson["GradeObjectIdentifier"].intValue)
                                    subsub.append(subJson["GradeObjectTypeName"].stringValue)
                                    subsub.append(subJson["PointsDenominator"].intValue)
                                    subsub.append(subJson["WeightedDenominator"].intValue)
                                    subsub.append(subJson["DisplayedGrade"].stringValue)
                                    subsub.append(subJson["Comments"].arrayValue)
                                    subsub.append(subJson["GradeObjectType"].stringValue)
                                    subsub.append(subJson["WeightedNumerator"].intValue)
                                    self.gradeobjects.updateValue(subsub, forKey: subJson["GradeObjectIdentifier"].stringValue)
                                }
//                                sub_arr.append(subJson["GradeObjectName"].stringValue)
//                                sub_arr.append(subJson["PointsNumerator"].intValue)
//                                sub_arr.append(subJson["PrivateComments"].arrayValue)
//                                sub_arr.append(subJson["GradeObjectIdentifier"].intValue)
//                                sub_arr.append(subJson["GradeObjectTypeName"].stringValue)
//                                sub_arr.append(subJson["PointsDenominator"].intValue)
//                                sub_arr.append(subJson["WeightedDenominator"].intValue)
//                                sub_arr.append(subJson["DisplayedGrade"].stringValue)
//                                sub_arr.append(subJson["Comments"].arrayValue)
//                                sub_arr.append(subJson["GradeObjectType"].stringValue)
//                                sub_arr.append(subJson["WeightedNumerator"].intValue)
                            }
                            print(self.categories)
                            self.tableView.reloadData()
                        case .failure(let error):
                            print("Request failed with error: \(error)")
                        }
                        
                    }
    }
    
    func retrieveClassContent(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        print("Requesting content...")
        // Note: to get the classlist: https://learn.colorado.edu/d2l/api/le/1.5/197814/classlist/
        
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
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
            //self.debugActivity.stopAnimating()
            
        }
    }

}
