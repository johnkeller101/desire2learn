//
//  FileBrowserViewController.swift
//  desire2learn
//
//  Created by John Keller on 10/7/16.
//  Copyright © 2016 John Keller. All rights reserved.
//

import UIKit
import SafariServices

class FileBrowserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView = UITableView()
    
    var name:String = ""
    var class_id:String = ""
    var files: Array = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height);
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        self.title = self.name
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        let files_sub = files[indexPath.row] as! NSArray
        let content_name = files_sub[0] as? String
        if files_sub[1] as? String == "0" {
            cell.textLabel?.text = "📁 "+content_name!
        } else {
            cell.textLabel?.text = "📄 "+content_name!
        }
        cell.detailTextLabel?.text = files_sub[1] as? String
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(files.count) items"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(indexPath.row)!)")
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let files_sub = files[indexPath.row] as! NSArray
        print(files_sub)
        let content_name = files_sub[0] as? String
        let content_id = files_sub[2] as? String
        if files_sub[1] as? String == "0" {
            //FOLDER
        } else {
            //FILE
            let safariVC = SFSafariViewController(url: URL(string: "https://learn.colorado.edu/d2l/le/content/\(self.class_id)/topics/files/download/\(content_id!)/DirectFileTopicDownload")!)
            safariVC.title = content_name
            self.navigationController?.pushViewController(safariVC, animated: true)
        }
        
        //https://learn.colorado.edu/d2l/le/content/172556/topics/files/download/2583306/DirectFileTopicDownload
        
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
