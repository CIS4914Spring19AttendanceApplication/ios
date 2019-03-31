//
//  OrganizationCell.swift
//  rollcall
//
//  Created by Samantha Eboli on 3/30/19.
//  Copyright © 2019 Samantha Eboli. All rights reserved.
//

import UIKit

class OrganizationCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detail: UILabel!
    
    func setInfo(n: String, d: String, min: Bool){
        name.text = n
        detail.text = d
        if(min){
            detail.textColor = UIColor.green
        }
        else{
            detail.textColor = UIColor.red
        }
    }
}
