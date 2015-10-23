//
//  ProfilesTableViewController.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 23.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import HealthKitSampleGenerator

class ProfilesTableViewController: UITableViewController {
    
    let formatter = NSDateFormatter()
    var profiles:[HealthkitProfile] = []
 
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = NSDateFormatterStyle.MediumStyle
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        profiles.removeAll()
        let documentsUrl    = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let enumerator = NSFileManager.defaultManager().enumeratorAtPath(documentsUrl.path!)
        for file in enumerator! {
            profiles.append(HealthkitProfile(fileAtPath:documentsUrl.URLByAppendingPathComponent(file as! String)))
        }
        tableView.reloadData()
    }
    
}

// TableView Datasource
extension ProfilesTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let profile = profiles[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("profileCell")!
        
        cell.textLabel?.text = profile.fileName
        
        print(profile)
        
        profile.loadMetaData({ (metaData:HealthkitProfileMetaData) in

            NSOperationQueue.mainQueue().addOperationWithBlock(){
                let from = metaData.creationDate != nil ? self.formatter.stringFromDate(metaData.creationDate!) : "unknown"
                let profileName = metaData.profileName != nil ? metaData.profileName! : "unknown"
                
                cell.detailTextLabel?.text = "\(profileName) from: \(from)"
            }

        })
        return cell
        
    }
}