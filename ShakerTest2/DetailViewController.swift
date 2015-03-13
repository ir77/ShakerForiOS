//
//  DetailViewController.swift
//  ShakerTest2
//
//  Created by ucuc on 3/12/15.
//  Copyright (c) 2015 ucuc. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var glayLayer: UIView!
    @IBOutlet weak var endMessage: UILabel!
    
    var detailItem: AnyObject?
    var dataSource = [NSDictionary]()
    let novelGameText = SRGNovelGameTexts()
    var chapterCounter = 0
    var paragraphCounter = 0
    var nowChapter = 0
    var nowParagraph = 0
    var isEnd = false
    
    // MARK: - Shaker Story
    func analyzeDataForChapter() {
        chapterCounter = self.dataSource[0]["chapters"]!.count
    }
    
    func analyzeDataForParagraph() {
        let array = self.dataSource[0]["chapters"]![nowChapter]["paragraphs"]! as NSArray
        paragraphCounter = array.count
    }
    
    func getNextChapterID() -> Int {
        let array = self.dataSource[0]["chapters"]![nowChapter]["branches"]! as NSArray
        if array.count == 1 {
            let nextChapterID = array[0]["next_chapter_id"]! as Int
            return searchNextChapterIndex(nextChapterID)
        } else if array.count > 1 {
            showButtons(array.count)
            return nowChapter
        } else {
            return -1
        }
    }
    
    func searchNextChapterIndex(nextChapterID:Int) -> Int {
        for (var i=0; i<chapterCounter; i++) {
            let chapter_id = self.dataSource[0]["chapters"]![i]["id"]! as Int
            if chapter_id == nextChapterID {
                return i
            }
        }
        return -1
    }
    
    func checkProgres() -> Bool {
        if nowParagraph == paragraphCounter {
            // TODO: Chapterを分岐させる
            if nowChapter == getNextChapterID() {
                return true
            }
            nowChapter = getNextChapterID()
            if nowChapter == -1 {
                println("########### ゲーム終了です ###########")
                self.glayLayer.hidden = false
                self.endMessage.hidden = false
                isEnd = true
                return true
            }
            analyzeDataForParagraph()
            nowParagraph = 0
        }
        return false
    }

    func play() {
        if checkProgres() {
            return 
        }
        let array = self.dataSource[0]["chapters"]![nowChapter]["paragraphs"]! as NSArray
        if array[nowParagraph]["command"] as String == "background" {
            let tmpStr = array[nowParagraph]["args"] as String
            let url = NSURL(string: "http://localhost:6543" + tmpStr)
            let req = NSURLRequest(URL:url!)
            
            NSURLConnection.sendAsynchronousRequest(req, queue:NSOperationQueue.mainQueue()){(res, data, err) in
                let image = UIImage(data:data)
                self.backgroundImage.image = image
            }
            self.nowParagraph++
            play()
            
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                let tmpStr = array[self.nowParagraph]["args"] as String
                self.novelGameText.frame = CGRectMake(10,357,355,310);
                self.novelGameText.setDisplayText(tmpStr)
                self.novelGameText.startDisplayingText()
                self.nowParagraph++
            }
        }
    }
    
    // MARK: - Gesture
    func onTap (recognizer:UIPanGestureRecognizer){
        if isEnd {
            chapterCounter = 0
            paragraphCounter = 0
            nowChapter = 0
            nowParagraph = 0
            self.analyzeDataForChapter()
            self.analyzeDataForParagraph()
            self.play()
            self.glayLayer.hidden = true
            self.endMessage.hidden = true
            isEnd = false
        } else if !self.novelGameText.isTextDisplayingCompleted {
            self.novelGameText.displayAllText()
        } else {
            self.novelGameText.cleanup()
            play()
        }
    }
    
    func tapped(sender: UIButton){
        println("Tapped Button Tag:\(sender.tag)")
        nowChapter = searchNextChapterIndex(sender.tag)
        self.novelGameText.cleanup()
        analyzeDataForParagraph()
        nowParagraph = 0
        self.glayLayer.hidden = true
        removeAllSubviews(self.view)
        play()
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.getParagraph()
        self.glayLayer.hidden = true
        self.endMessage.hidden = true
        
        //ジェスチャー登録
        let _singleTap = UITapGestureRecognizer(target: self, action: "onTap:");
        _singleTap.numberOfTapsRequired = 1;
        view.addGestureRecognizer(_singleTap);
        
        // テキスト出力用のViewを初期化
        self.novelGameText.frame = CGRectMake(10,357,355,310);
        self.novelGameText.textColor = UIColor.blackColor()
        self.novelGameText.font = UIFont.boldSystemFontOfSize(20)
        self.view.addSubview(novelGameText)
    }
    
    func showButtons(buttonCount:Int) {
        self.glayLayer.hidden = false
        
        for (var i=0; i<buttonCount; i++) {
            let button = UIButton()
            //表示されるテキスト
            let array = self.dataSource[0]["chapters"]![nowChapter]["branches"]! as NSArray
            let message = array[i]["message"]! as String
            let nextChapterID = array[i]["next_chapter_id"] as Int

            button.setTitle(message, forState: .Normal)
            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            button.frame = CGRectMake(0, 0, 300, 50)
            button.tag = nextChapterID
            button.layer.position = CGPoint(x: self.view.frame.width/2, y: CGFloat(100*(i+1)))
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.backgroundColor = UIColor.blueColor()
            button.backgroundColor = UIColor(red: 0.0, green: 0.588, blue: 0.859, alpha: 1.0)
            button.layer.cornerRadius = 10
            button.addTarget(self, action: "tapped:", forControlEvents:.TouchUpInside)
            self.view.addSubview(button)
        }
    }
    
    func removeAllSubviews(parentView: UIView){
        var subviews = parentView.subviews
        for subview in subviews {
            if subview.tag > 0 {
                subview.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Network
    func getParagraph() {
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
                    self.analyzeDataForChapter()
                    self.analyzeDataForParagraph()
                    self.play()
                } else {
                    println(error)
                }
            })
            task.resume()
        }
    }
    
    // MARK: - Other
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

