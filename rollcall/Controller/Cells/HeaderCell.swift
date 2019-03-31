//
//  HeaderCell.swift
//  rollcall
//
//  Created by Samantha Eboli on 3/30/19.
//  Copyright © 2019 Samantha Eboli. All rights reserved.
//

import UIKit

class HeaderCell: UITableViewCell {
    @IBOutlet weak var heading: UILabel!
    
    func setInfo(title: String){
        heading.text = title
    }

}
