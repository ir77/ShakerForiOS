//
//  CustomCell.swift
//  shakerTest
//
//  Created by ucuc on 3/12/15.
//  Copyright (c) 2015 ucuc. All rights reserved.
//

import UIKit

class CustomCell: UICollectionViewCell {
    @IBOutlet var title:UILabel!
    @IBOutlet var image:UIImageView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
}