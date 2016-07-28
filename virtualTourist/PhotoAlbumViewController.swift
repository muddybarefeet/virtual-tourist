//
//  PhotoAlbumViewController.swift
//  virtualTourist
//
//  Created by Anna Rogers on 7/25/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

//import Foundation
import UIKit
import MapKit

class PhotoAlbumViewController: UICollectionViewController {
    
    let Flickr = FlickrClient.sharedInstance
    //deal with data persistence
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in collection view")
        Flickr.getImagesForLocation(latitude, long: longitude) { (data, error) in
            if (data != nil) {
                print("data", data)
            } else {
                print("error", error)
            }
        }
    }
    
    //call the Flickr API with the lat and long
    
    
}