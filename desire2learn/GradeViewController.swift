//
//  GradeViewController.swift
//  desire2learn
//
//  Created by John Keller on 10/7/16.
//  Copyright © 2016 John Keller. All rights reserved.
//

import UIKit
import SafariServices

class GradeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView = UITableView()
    
    var name:String = ""
    var class_id:String = ""
    var cat_weight:String = ""
    var grades: Array = [Any]()
    
    var catinfo:Array = [Any]()
    var gradeobjects = [String:Any]()
    
    var displayPoints = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height);
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        let refreshButton = UIBarButtonItem(title: "%", style: .plain, target: self, action: #selector(GradeViewController.switchView))
        navigationItem.rightBarButtonItem = refreshButton
        
        self.title = self.name
        // Do any additional setup after loading the view.
    }
    
    func switchView() {
        displayPoints = !displayPoints
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        cell.textLabel?.textColor = .white
        
        cell.textLabel!.lineBreakMode = .byTruncatingTail
        cell.layoutSubviews()
        
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption2)
        cell.detailTextLabel?.textColor = .white
        cell.detailTextLabel?.backgroundColor = cell.backgroundColor
        
        
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        if indexPath.section == 0 {
            let sub = grades[indexPath.row] as! NSArray
//        let arr:NSArray = gradeobjects[sub[2] as! String] as! NSArray
            
//            print(sub[2] as! String)
            let content_name = sub[0] as? String
            let g_max = sub[2] as? String
            cell.textLabel?.text = content_name
            if gradeobjects[sub[1] as! String] != nil {
                let arr:NSArray = gradeobjects[sub[1] as! String] as! NSArray
                if displayPoints {
                    cell.detailTextLabel?.text = (arr[1] as! NSNumber).stringValue+"/"+g_max!
                } else {
                    cell.detailTextLabel?.text = ((arr[7] as? String)?.replacingOccurrences(of: " ", with: ""))!
                }
                
            } else {
                if displayPoints {
                    cell.detailTextLabel?.text = "-/"+g_max!
                } else {
                    cell.detailTextLabel?.text = "-%"
                }
            }
        } else {
            cell.textLabel?.text = self.name+" Total"
            if displayPoints {
                cell.detailTextLabel?.text = (catinfo[1] as! NSNumber).stringValue.replacingOccurrences(of: " ", with: "")+"/"+(catinfo[5] as! NSNumber).stringValue.replacingOccurrences(of: " ", with: "")
            } else {
                cell.detailTextLabel?.text = (catinfo[7] as! String).replacingOccurrences(of: " ", with: "")
            }
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return grades.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if grades.count == 1 {
                return "\(grades.count) grade"
            } else {
                return "\(grades.count) grades"
            }
            
        } else {
            return "total"
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(indexPath.row)!")
        let sub = grades[indexPath.row] as! NSArray
        if gradeobjects[sub[1] as! String] != nil {
            let arr:NSArray = gradeobjects[sub[1] as! String] as! NSArray
            debugPrint(arr)
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)

    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
