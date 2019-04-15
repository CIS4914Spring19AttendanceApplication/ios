//
//  PointsCell.swift
//  rollcall
//
//  Created by Samantha Eboli on 3/30/19.
//  Copyright © 2019 Samantha Eboli. All rights reserved.
//

import UIKit

class PointsCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var details: UILabel!
    
    func setInfo(n: String, d: String, min: Bool){
        name.text = n
        details.text = d
        
        if(min){
            details.textColor = UIColor.green
        }
        else{
            details.textColor = UIColor.red
        }
    }

}
