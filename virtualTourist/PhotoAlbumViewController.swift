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
    
    //deal with data persistence
    var coordinates: CLLocationCoordinate2D!
    
    override func viewWillAppear(animated: Bool) {
        print("in collection view will appear", coordinates)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in collection view", coordinates)
    }
    
    
}