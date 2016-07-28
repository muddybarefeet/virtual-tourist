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
                //now display the data to the user
            } else {
                print("error", error)
            }
        }
    }
    
    //random image page choose from API
    //display collection view of photos
    //add update collection button - how to overwrite images saved? And when to save a collection
    //delete photo
    //Add a README doc
    
}