//
//  Photo.swift
//  virtualTourist
//
//  Created by Anna Rogers on 7/30/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

    convenience init(url: String,  context : NSManagedObjectContext){
        
        if let ent = NSEntityDescription.entityForName("Photo",
                                                       inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.url = url
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
