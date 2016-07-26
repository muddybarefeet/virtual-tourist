//
//  TravelLocationsMapView.swift
//  virtualTourist
//
//  Created by Anna Rogers on 7/25/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

//import Foundation
import UIKit
import MapKit
import CoreData

class TravelLocationsMapView: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    //deal with user map interation -> modally present next controller on tap of a pin
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the pins created
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.pins
        
        let fr = NSFetchRequest(entityName: "Pin")
        //fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),
                              //NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let longUIPress = UILongPressGestureRecognizer(target: self, action: #selector(self.action))
        longUIPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longUIPress)
    }
    
    func action(gestureRecognizer:UIGestureRecognizer){
        print("action to add annotation called")
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
    }
    
}
