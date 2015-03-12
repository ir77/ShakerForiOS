//
//  MasterViewController.swift
//  ShakerTest2
//
//  Created by ucuc on 3/12/15.
//  Copyright (c) 2015 ucuc. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController,  UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource = [AnyObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        println("http://localhost:6543/api/v1/projects")
        var urlString = "http://localhost:6543/api/v1/projects"
        var url = NSURL(string: urlString)
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        var task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler:{data, response, error in
            self.dataSource = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments,error: nil) as NSArray
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView.reloadData()
            }
        })
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let cell = sender as CustomCell
            let object: (AnyObject) = self.dataSource[cell.tag]
            (segue.destinationViewController as DetailViewController).detailItem = object
        }
    }

    // MARK: - Collection View
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:CustomCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as CustomCell
        updateCell(cell, cellForRowAtIndexPath: indexPath)
        return cell
    }
    
    private func updateCell( cell : CustomCell, cellForRowAtIndexPath indexPath : NSIndexPath) {
        let row = indexPath.row
        cell.tag = row
        // cell.title.text = self.dataSource[row]["title"] as NSString
        let tmpURL:String = self.dataSource[row]["package"] as String
        let url = NSURL(string: "http://localhost:6543" + tmpURL)
        let req = NSURLRequest(URL:url!)
        
        NSURLConnection.sendAsynchronousRequest(req, queue:NSOperationQueue.mainQueue()){(res, data, err) in
            let image = UIImage(data:data)
            cell.image.image = image
        }
        cell.backgroundColor = UIColor.whiteColor()
        cell.layoutIfNeeded()
    }
    
    private func updateVisibleCells () {
        for cell in collectionView.visibleCells() {
            updateCell(cell as CustomCell, cellForRowAtIndexPath: collectionView.indexPathForCell(cell as CustomCell)!)
        }
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count;
    }
}

