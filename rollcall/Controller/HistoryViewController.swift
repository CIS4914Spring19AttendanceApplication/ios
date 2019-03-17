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
    var totalPoints = Int()
    var events = [eventData]()
}

struct eventData{
    var opened = Bool()
    var name = String()
    var eventData = [String : Any]()
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
        //store the first org name
        var currentOrg = results[0]["org_name"] as! String
        var org = orgData(opened: false, name: currentOrg, totalPoints: 0, events: [])
        
        var points: Int = 0
        //loop through all of the results
        for event in results{
            let org_name = event["org_name"] as! String
            if(org_name != currentOrg){
                //once done with an org, add it to the array and reset points
                org.totalPoints = points
                points = 0
                historyData.append(org)
                
                currentOrg = event["org_name"] as! String
                org = orgData(opened: false, name: currentOrg, totalPoints: 0, events: [])
            }
            let currentEvent = eventData(opened: false, name: event["name"]! as! String, eventData: event)
            org.events.append(currentEvent)
            
            //calculate the number of points in the event
            let p = currentEvent.eventData["point_categories"] as! [Dictionary<String,Any>]
            for cat in p{
                points = points + (cat["points"] as! Int)
            }
        }
        
        //add the final org to the array after exiting the loop
        org.totalPoints = points
        historyData.append(org)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return historyData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if that section is opened
        if(historyData[section].opened == true){
            return historyData[section].events.count + 1
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
        
        if(indexPath.row == 0){
            guard let cell = orgTable.dequeueReusableCell(withIdentifier: "basicCell") else {return UITableViewCell()}
            cell.textLabel?.text = historyData[indexPath.section].name
            cell.detailTextLabel?.text = String(historyData[indexPath.section].totalPoints)
            cell.detailTextLabel?.textColor = UIColor.green
            return cell
        }
        else{
            guard let cell = orgTable.dequeueReusableCell(withIdentifier: "eventCell") else {return UITableViewCell()}
            cell.textLabel?.text = historyData[indexPath.section].events[indexPath.row - 1].name
            
            let date = historyData[indexPath.section].events[indexPath.row - 1].eventData["date"] as! String
            let location = historyData[indexPath.section].events[indexPath.row - 1].eventData["location"] as! String
            //get the points categories
            let points = historyData[indexPath.section].events[indexPath.row - 1].eventData["point_categories"] as! [Dictionary<String,Any>]
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
            cell.detailTextLabel?.text = date + ", " + location + ", " + point_des
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            if (historyData[indexPath.section].opened == true){
                historyData[indexPath.section].opened = false
                let eventSections = IndexSet.init(integer: indexPath.section)
                orgTable.reloadSections(eventSections, with: .none)
            }
            else{
                historyData[indexPath.section].opened = true
                let eventSections = IndexSet.init(integer: indexPath.section)
                orgTable.reloadSections(eventSections, with: .none)
            }
        }
    }
}
