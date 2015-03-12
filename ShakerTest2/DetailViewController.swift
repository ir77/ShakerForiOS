//
//  DetailViewController.swift
//  ShakerTest2
//
//  Created by ucuc on 3/12/15.
//  Copyright (c) 2015 ucuc. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    var detailItem: AnyObject?
    var dataSource = [NSDictionary]()

    func configureView() {
        if let detail: AnyObject = self.detailItem {
            var urlString = "http://localhost:6543/api/v1/play?project_id="
            if let project_id = detail["id"] as? Int {
                urlString = urlString + String(project_id)
            }
            println (urlString)
            var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
            request.HTTPMethod = "GET"
            var task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error in
                if (error == nil) {
                    //convert json data to dictionary
                    self.dataSource.append(NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary)
                    self.play()
                } else {
                    println(error)
                }
            })
            task.resume()
        }
    }
    
    func play() {
        println(self.dataSource[0]["project"]!["id"]!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

