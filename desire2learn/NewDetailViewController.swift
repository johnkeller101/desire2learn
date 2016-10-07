//
//  NewDetailViewController.swift
//  desire2learn
//
//  Created by John Keller on 10/6/16.
//  Copyright © 2016 John Keller. All rights reserved.
//

import UIKit

class NewDetailViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    var html:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(html)
        self.webView.loadHTMLString(html, baseURL: (URL (string: "https://learn.colorado.edu/d2l/le/")))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
