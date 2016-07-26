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

class TravelLocationsMapView: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    //deal with user map interation -> modally present next controller on tap of a pin
    override func viewDidLoad() {
        super.viewDidLoad()
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
