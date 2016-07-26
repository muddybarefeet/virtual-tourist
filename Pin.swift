//
//  Pin.swift
//  virtualTourist
//
//  Created by Anna Rogers on 7/26/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import Foundation
import CoreData


class Pin: NSManagedObject {

    //when making a new instance of the model then instantiat with the following properties
    convenience init(lat: Double, long: Double,  context : NSManagedObjectContext){
        if let ent = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.latitude = lat
            self.longitude = long
            self.createdAt = NSDate()
        }else{
            fatalError("Unable to find Entity name!")
        }
    }
    
    var humanReadableAge : String{
        get{
            let fmt = NSDateFormatter()
            fmt.timeStyle = .NoStyle
            fmt.dateStyle = .ShortStyle
            fmt.doesRelativeDateFormatting = true
            fmt.locale = NSLocale.currentLocale()
            
            return fmt.stringFromDate(createdAt!)
        }
    }

}
