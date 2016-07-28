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
    
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    let Flickr = FlickrClient.sharedInstance
    //deal with data persistence
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var photos: [String] = []
    
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustFlowLayout(view.frame.size)
        activitySpinner.center = self.view.center
        print("in collection view")
        Flickr.getImagesForLocation(latitude, long: longitude) { (data, error) in
            if (data!.count > 0) {
                //save data to store
                if let data = data {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.photos = data
                        //RELOAD DATA to show in collection
                        self.collectionView!.reloadData()
                        print("photos saved")
                        self.activitySpinner.startAnimating()
                        self.view.addSubview(self.activitySpinner)
                    }
                } else {
                    //THROW ERROR THAT DATA NOT THERE
                }
            } else {
                print("error", error)
            }
        }
    }
    
    //random image page choose from API on click of new collection button else just display first page
    //add update collection button - how to overwrite images saved? And when to save a collection
    //delete photo
    //Add a README doc
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionCellViewController
        //download the image and get the data
        
        Flickr.getImageData(photos[indexPath.row]) { (data, error) in
            if data != nil {
                print("show image")
                let downloadedImage = data
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    cell.photoView.image = downloadedImage
                }
            } else {
                print("bad data of image nothing returned")
            }
        }
        return cell
    }
    
//    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
//        print("FINISJED DISPLAYING CONTENT")
//        self.activitySpinner.stopAnimating()
//        self.view.willRemoveSubview(self.activitySpinner)
//    }
    
    override func collectionView(collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        print("DID FINISH")
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        adjustFlowLayout(size)
    }
    
    func adjustFlowLayout(size: CGSize) {
        let space: CGFloat = 2.0
        let dimension:CGFloat = size.width >= size.height ? (size.width - (5 * space)) / 6.0 :  (size.width - (2 * space)) / 3.0
        flowLayout.minimumLineSpacing = 2.0
        flowLayout.minimumInteritemSpacing = 2.0
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        
    }
    
}