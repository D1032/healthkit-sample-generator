//
//  DataExporterTest.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 19.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
import Quick
import Nimble
import HealthKit
@testable import HealthKitSampleGenerator

class DataExporterTest: QuickSpec {
    
    let healthStore = HealthKitStoreMock()
    
    let profileName = "testName"

    
    override func spec() {
 
        let exportConfiguration = HealthDataFullExportConfiguration(profileName: self.profileName, exportType: HealthDataToExportType.ALL)
        
        describe("MetaData and UserData Export") {
        
            
            it ("should export the meta data") {
            
                let exporter = MetaDataExporter(exportConfiguration: exportConfiguration)
                
                let target = JsonSingleDocInMemExportTarget()
                try! target.startExport()
                
                try! exporter.export(self.healthStore, exportTargets: [target])
                
                try! target.endExport()
                                
                let metaDataDict = JsonReader.toJsonObject(target.getJsonString(), returnDictForKey:"metaData")
                
                expect(metaDataDict["creationDate"] as? NSNumber).notTo(beNil())
                expect(metaDataDict["profileName"] as? String)  == self.profileName
                expect(metaDataDict["version"] as? String)      == "0.2.0"
                expect(metaDataDict["type"] as? String)         == "JsonSingleDocExportTarget"

            }
            
            it ("should export the user data") {
                let exporter = UserDataExporter(exportConfiguration: exportConfiguration)
                
                let target = JsonSingleDocInMemExportTarget()
                try! target.startExport()
                
                try! exporter.export(self.healthStore, exportTargets: [target])
                
                try! target.endExport()
                
                let userDataDict = JsonReader.toJsonObject(target.getJsonString(), returnDictForKey:"userData")
                
                let dateOfBirth         = userDataDict["dateOfBirth"] as? NSNumber
                let biologicalSex       = userDataDict["biologicalSex"] as? Int
                let bloodType           = userDataDict["bloodType"] as? Int
                let fitzpatrickSkinType = userDataDict["fitzpatrickSkinType"] as? Int
                
                let date = NSDate(timeIntervalSince1970: (dateOfBirth?.doubleValue)! / 1000.0)
                
                expect(try! self.healthStore.dateOfBirth())  == date
                
                expect(biologicalSex)       == HKBiologicalSex.Male.rawValue
                expect(bloodType)           == HKBloodType.APositive.rawValue
                expect(fitzpatrickSkinType) == HKFitzpatrickSkinType.I.rawValue
                
            }
        }
        
        describe("QuantityType Exports") {
            
            it("should export quantity data") {
                let type  = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!
                let strUnit = "kg"
                let unit = HKUnit(fromString: strUnit)
                
                let exporter = QuantityTypeDataExporter(exportConfiguration: exportConfiguration, type: type, unit: unit)
                
                let target = JsonSingleDocInMemExportTarget()
                try! target.startExport()
                
                try! target.startWriteQuantityType(type, unit:unit)
                try! target.startWriteDatas()
                
                let quantity = HKQuantity(unit: unit, doubleValue: 70)
                let sample = HKQuantitySample(type: type, quantity: quantity, startDate: NSDate(), endDate: NSDate())
                
                try! exporter.writeResults([sample], exportTargets: [target])
                try! target.endWriteDatas()
                try! target.endWriteType()
                
                try! target.endExport()
                
                let sampleDict = JsonReader.toJsonObject(target.getJsonString(), returnDictForKey:String(HKQuantityTypeIdentifierBodyMass))
                
               
                let unitValue = sampleDict["unit"]
                expect(unitValue as? String) == strUnit
                
                let dataArray = sampleDict["data"] as? [AnyObject]
                
                expect(dataArray?.count) == 1
                
                let savedSample = dataArray?.first as! Dictionary<String, AnyObject>
             
                
                let edate   = savedSample["edate"] as! NSNumber
                let sdate   = savedSample["sdate"] as! NSNumber
                let uuid    = savedSample["uuid"] as! String
                let value   = savedSample["value"] as! NSNumber
                
                expect(edate).to(beCloseTo(sdate, within: 1000))
                expect(uuid).notTo(beNil())
                expect(value) == quantity.doubleValueForUnit(unit)
            }
        }

    
        describe("CategoryTypeDataExporter") {
            it ("should export category types"){
                let type = HKObjectType.categoryTypeForIdentifier(HKCategoryTypeIdentifierAppleStandHour)!
                
                let exporter = CategoryTypeDataExporter(exportConfiguration: exportConfiguration, type: type)
                
                let target = JsonSingleDocInMemExportTarget()
                try! target.startExport()
                try! target.startWriteType(type)
                try! target.startWriteDatas()
                
                let sample = HKCategorySample(type: type, value: 1, startDate: NSDate(), endDate: NSDate())
                
                try! exporter.writeResults([sample], exportTargets: [target])
                
                
                try! target.endWriteDatas()
                try! target.endWriteType()
                
                try! target.endExport()
                
                print(target.getJsonString())
                
                let sampleDict = JsonReader.toJsonObject(target.getJsonString(), returnDictForKey:String(HKCategoryTypeIdentifierAppleStandHour))
                
                let dataArray = sampleDict["data"] as? [AnyObject]
                
                expect(dataArray?.count) == 1
                
                let savedSample = dataArray?.first as! Dictionary<String, AnyObject>
                
                let edate   = savedSample["edate"] as! NSNumber
                let sdate   = savedSample["sdate"] as! NSNumber
                let uuid    = savedSample["uuid"] as! String
                let value   = savedSample["value"] as! NSNumber
                
                expect(edate).to(beCloseTo(sdate, within: 1000))
                expect(uuid).notTo(beNil())
                expect(value) == 1
            
            }
        }
        
    }
    
}