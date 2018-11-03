//
//  NewDetailViewController.swift
//  desire2learn
//
//  Created by John Keller on 10/6/16.
//  Copyright © 2016 John Keller. All rights reserved.
//

import UIKit
import SafariServices

class NewDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView = UITableView()
    
    var html:String = ""
    var newstitle:String = ""
    var class_id:String = ""
    var article_id:String = ""
    var attachments: Array = [Any]()
    var details: Array = [Any]()

    var contentView:UITextView = UITextView()
    let inset:CGFloat = 10
    let tinset:CGFloat = 5
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(article_id)
        print(html)
        
        // generate the content!
        
        
        
        tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height);
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        self.title = self.newstitle
        
        tableView.estimatedRowHeight = 44.0 // Replace with your actual estimation
        // Automatic dimensions to tell the table view to use dynamic height
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        let baseFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        let modifier = modifierWithBaseAttributes([NSFontAttributeName: baseFont], modifiers: [
            selectMap("em", italic),
            selectMap("a", italic),
            selectMap("span.bold", bold),
            ])
        
        let attributedString = NSAttributedString.attributedStringFromMarkup(html, withModifier: modifier)
        contentView.attributedText = attributedString
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        
        
        if indexPath.section == 0 {
            cell.textLabel?.text = ""
            
            contentView.tag = 2
            contentView.isScrollEnabled = false

            
            
           // contentView.attributedText = attributedString
            contentView.isEditable = false
            
            

            let fixedWidth = self.view.frame.size.width
            contentView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            let newSize = contentView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = CGRect(x: inset, y: inset, width: newSize.width - (inset*2), height: newSize.height - (inset*2))
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth)-(inset*2), height: newSize.height)
            contentView.frame = newFrame;
            contentView.backgroundColor = cell.backgroundColor
            cell.addSubview(contentView)
            //let parser = parser
            
        } else if indexPath.section == 1{
            let t = attachments[indexPath.row] as! NSArray
            let ti = t[0] as? String
            let size_str = t[1] as! NSString
            var size = Double(size_str as String)
            size = (size! / 1000)
            var ex:String = ""
            switch size {
            case _ where size! < Double(500):
                ex = "kB"
                size = Double(round(10*size!)/10)
            case _ where size! > Double(500):
                
                size = size! / 1000
                ex = "MB"
                size = Double(round(100*size!)/100)
            default:
                ex = "kB"
            }
            
            cell.textLabel?.text = "📄 "+ti!
            cell.detailTextLabel?.text = String(describing: size!)+" "+ex
        } else {
            cell.textLabel?.text = details[indexPath.row] as? String
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return attachments.count
        } else {
            return details.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "content"
        } else if section == 1 {
            if attachments.count > 0 {
                return "attachments"
            } else {
                return nil
            }
        } else {
            return "details"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(indexPath.row)!)")
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0{
            
        } else if indexPath.section == 1{
            let t = attachments[indexPath.row] as! NSArray
            let file_id = t[2] as! String
            // https://learn.colorado.edu/d2l/le/news/widget/172556/FileProvider?newsId=222447&fileId=3252523
            let vc = FileAttachmentViewController()
            vc.url = "https://learn.colorado.edu/d2l/le/news/widget/\(self.class_id)/FileProvider?newsId=\(article_id)&fileId=\(file_id)"
            vc.name = (t[0] as? String)!
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return contentView.frame.size.height + (inset*2)
        } else {
            return 44
        }
    }
}
