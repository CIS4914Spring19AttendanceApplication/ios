//
//  HistoryViewController.swift
//  rollcall
//
//  Created by Samantha Eboli on 3/14/19.
//  Copyright © 2019 Samantha Eboli. All rights reserved.
//

import UIKit
import Alamofire

struct orgData{
    var opened = Bool()
    var name = String()
    var events = [Dictionary<String, Any>]()
    var points = [Dictionary<String, Any>]()
}

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var myOrgTitle: UILabel!
    @IBOutlet weak var orgTable: UITableView!
    
    var historyData = [orgData]()
    
    let GET_HISTORY_URL = "http://Samanthas-MacBook-Pro-2.local:8080/api/user/history/"
    let sessionManager = SessionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orgTable.delegate = self
        orgTable.dataSource = self
        
        myOrgTitle.text = "\(Data.sharedInstance.userData[1])'s Organizations"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        historyData.removeAll()
        
        let historyURL = GET_HISTORY_URL + Data.sharedInstance.userData[0]
        self.sessionManager.adapter = AccessTokenAdapter(accessToken: Data.sharedInstance.accessToken!)
        self.sessionManager.request(historyURL, method: .get, encoding: JSONEncoding.default).responseData{
            response in
            if let status = response.response?.statusCode{
                print(historyURL)
                print("status \(status)")
                switch(status){
                case 200:
                    //print(response.result.value)
                    
                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with:
                            response.data!, options: []) as! [Dictionary<String,Any>]
                       
                        self.formatHistoryData(results: jsonResponse)
                        self.orgTable.reloadData()
                    }
                    catch{
                        print(error)
                    }
                default:
                    break
                }
            }
        }
    }
    
    func formatHistoryData(results : [Dictionary<String, Any>]){
        //loop through all of the returned results
        for org in results{
            let currentOrg = orgData(opened: false, name: org["org"] as! String, events: org["events"] as! [[String : Any]], points: org["point_status"] as! [[String : Any]])
            historyData.append(currentOrg)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return historyData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(historyData[section].opened == true){
            return historyData[section].events.count + historyData[section].points.count + 2
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //if there are no enrolled organizations
        if(historyData.isEmpty){
            guard let cell = orgTable.dequeueReusableCell(withIdentifier: "basicCell") else {return UITableViewCell()}
            cell.textLabel?.text = "You are not enrolled in any organizations yet!"
            return cell
        }
        let numEvents = historyData[indexPath.section].events.count + 2
        
        if(indexPath.row == 0){
            let cell = orgTable.dequeueReusableCell(withIdentifier: "basicCell") as! OrganizationCell
            
            let totalPointCats = historyData[indexPath.section].points.count
            let curr = historyData[indexPath.section].points[totalPointCats - 1]["current_points"] as! Int
            let total = historyData[indexPath.section].points[totalPointCats - 1]["total_points"] as! Int
            let details = String(curr) + "/" + String(total)
            cell.setInfo(n: historyData[indexPath.section].name, d: details, min: (curr >= total))

            return cell
        }
        else if(indexPath.row == 1){
            let cell = orgTable.dequeueReusableCell(withIdentifier: "subHeader") as! HeaderCell
            cell.setInfo(title: "Events Attended")
            return cell
        }
        else if (indexPath.row == numEvents){
            let cell = orgTable.dequeueReusableCell(withIdentifier: "subHeader") as! HeaderCell
            cell.setInfo(title: "Points Earned")
            return cell
        }
        else if (indexPath.row > numEvents) {
            //add the cells for the current point standings
             let cell = orgTable.dequeueReusableCell(withIdentifier: "pointCell") as! PointsCell

            let currentPoints = historyData[indexPath.section].points[indexPath.row - numEvents - 1]["current_points"] as! Int
            let neededPoints = historyData[indexPath.section].points[indexPath.row - numEvents - 1]["total_points"] as! Int

            let name = historyData[indexPath.section].points[indexPath.row - numEvents - 1]["category"] as? String
            let details = String(currentPoints) + "/" + String(neededPoints)
            cell.setInfo(n: name!, d: details, min: (currentPoints >= neededPoints))
            return cell
        }
        else{
            let cell = orgTable.dequeueReusableCell(withIdentifier: "detailCell") as! EventCell
            let row = indexPath.row - 2
            let name = historyData[indexPath.section].events[row]["name"] as? String

            let dateString = historyData[indexPath.section].events[row]["date"] as? String
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            let date = formatter.date(from: dateString!)
            
            formatter.dateFormat = "MM"
            let month = formatter.string(from: date!)
            formatter.dateFormat = "dd"
            let day = formatter.string(from: date!)

            let location = historyData[indexPath.section].events[row]["location"] as? String
            //get the points categories

            let points = historyData[indexPath.section].events[row]["point_categories"] as! [Dictionary<String,Any>]
            var point_des = String()
            for (i,cat) in points.enumerated(){
                let p = String(cat["points"] as! Int)
                point_des.append(p + " ")
                point_des.append(cat["name"] as! String)
                if(i != points.count - 1){
                    point_des.append(", ")
                }
            }
            point_des.append(" point(s)")
            let details = month + "/" + day + ", " + location! + ", " + point_des
            
            cell.setInfo(n: name!, d: details)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            if (historyData[indexPath.section].opened == true){
                historyData[indexPath.section].opened = false
                let subHeadings = IndexSet.init(integer: indexPath.section)
                orgTable.reloadSections(subHeadings, with: .none)
            }
            else{
                historyData[indexPath.section].opened = true
                let subHeadings = IndexSet.init(integer: indexPath.section)
                orgTable.reloadSections(subHeadings, with: .none)
            }
        }
    }
}
