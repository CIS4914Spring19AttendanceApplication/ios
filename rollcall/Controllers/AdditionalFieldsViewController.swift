//
//  AdditionalFieldsViewController.swift
//  rollcall
//
//  Created by Samantha Eboli on 2/22/19.
//  Copyright © 2019 Samantha Eboli. All rights reserved.
//

import UIKit

class AdditionalFieldsViewController: UIViewController {
    var addFields : [Dictionary<String,Any>]!
    @IBOutlet weak var questionTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0...addFields.count-1{
            let cell = UITableViewCell()
            let label = UILabel()
            label.numberOfLines = 3
            label.text = addFields[i]["question"] as? String
            label.textAlignment = .center
            
            cell.addSubview(label)
            questionTable.addSubview(cell)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
