//
//  MapViewDelegate.swift
//  virtualTourist
//
//  Created by Anna Rogers on 7/25/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit
import MapKit

class MapViewDelegate: NSObject, MKMapViewDelegate {
    
    //on click and hold = add a pin
    
    //on click a pin geocode the address and show modal of the images from that location mapView:didSelectAnnotationView:
    
//    // method to place the pin on the map and how it is styled
//    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        let reuseId = "pin"
//        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
//        if pinView == nil {
//            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//            //tell the pin if extra information can be show about the pin boolean
//            pinView!.canShowCallout = true
//            pinView!.pinTintColor = UIColor.redColor()
//            //view to display on the right side of the standard callout bubble
//            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
//        }
//        else {
//            pinView!.annotation = annotation
//        }
//        return pinView
//    }
    
    //on click of a pin, open the url in the subtitle
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("pin clicked", view.annotation?.coordinate)
//        if control == view.rightCalloutAccessoryView {
//            let app = UIApplication.sharedApplication()
//            if var mediaURL = (view.annotation?.subtitle!)! as String? {
//                if (mediaURL.hasPrefix("www")) {
//                    //add https:// to the front if they do not have this
//                    mediaURL = "https://" + mediaURL
//                }
//                let nsURL = NSURL(string: mediaURL)!
//                let isOpenable = app.canOpenURL(nsURL)
//                if isOpenable {
//                    app.openURL(nsURL)
//                } else {
//                    print("error in the URL")
//                }
//            }
//        }
    }
    
}