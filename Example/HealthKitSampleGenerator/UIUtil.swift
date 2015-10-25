//
//  UIUtil.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 25.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class UIUtil {
    
    let formatter = NSDateFormatter()
    let fileNameFormatter = NSDateFormatter()
    
    static let sharedInstance = UIUtil()
    
    private init(){
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = NSDateFormatterStyle.MediumStyle
        
        fileNameFormatter.dateFormat = "yyyyMMddHHmmss"
    }
    
    func formatDate(date:NSDate?) -> String {
        return date != nil ? formatter.stringFromDate(date!) : "unknown"
    }
    
    func formatDateForFileName(date:NSDate?) -> String {
        return date != nil ? fileNameFormatter.stringFromDate(date!) : "unknown"
    }
}