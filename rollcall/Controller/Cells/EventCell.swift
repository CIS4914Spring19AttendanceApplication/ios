//
//  EventCell.swift
//  rollcall
//
//  Created by Samantha Eboli on 3/30/19.
//  Copyright © 2019 Samantha Eboli. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var details: UILabel!
    
    func setInfo(n: String, d: String){
        name.text = n
        details.text = d
    }

}
