//
//  Pin.swift
//  virtualTourist
//
//  Created by Anna Rogers on 7/30/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import Foundation
import CoreData


class Pin: NSManagedObject {

    convenience init(lat: Double, long: Double, context : NSManagedObjectContext){
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entityForName("Pin",
                                                       inManagedObjectContext: context){
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
