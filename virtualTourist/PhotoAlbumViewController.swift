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
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource {
    
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let Flickr = FlickrClient.sharedInstance

    var currentPin: Pin?
    
    //var photos: [String] = FlickrClient.sharedInstance.photos
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentPin?.photo == nil || currentPin?.photo?.count == 0 {
            print("no pics currently")
            //then we need some pics from Flickr to display
//            Flickr.getImagesForLocation(Double((currentPin?.latitude)!), long: Double((currentPin?.longitude)!), recall: false) { (data, error) in
//                if (data!.count > 0) {
//                    //save data to store
//                    if let data = data {
//                        NSOperationQueue.mainQueue().addOperationWithBlock {
//                            self.Flickr.photos = data
//                            //RELOAD DATA to show in collection
//                            self.collectionView.reloadData()
//                            print("photos saved", self.Flickr.photos.count)
//                        }
//                    } else {
//                        //THROW ERROR THAT DATA NOT THERE
//                    }
//                } else {
//                    print("error", error)
//                }
//            }
        } else {
            //display the images already saved
            print("already have images")
        }
        
        //else the false key is already set so nothing else needs doing add pin and segue
        collectionView.delegate = self
        collectionView.dataSource = self
        adjustFlowLayout(view.frame.size)
        
    }
    
    
    //add update collection button - how to overwrite images saved? And when to save a collection
    //delete photo
    //Add a README doc
    //throw WARNING if the total page count is ONE to let the user know that they will never see more than current images
    
    @IBAction func getNewAlbum(sender: AnyObject) {
        //logic to get new selection of photos
        Flickr.getImagesForLocation(Double((currentPin?.latitude)!), long: Double((currentPin?.longitude)!), recall: true) { (data, error) in
            if (data!.count > 0) {
                if let data = data {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.Flickr.photos = data
                        self.collectionView.reloadData()
                        print("photos saved", self.Flickr.photos.count)
                    }
                }
            } else {
                print("error", error)
            }
            
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        adjustFlowLayout(size)
    }
    
    func adjustFlowLayout(size: CGSize) {
        let space: CGFloat = 3.0
        let dimension:CGFloat = size.width >= size.height ? (size.width - (5 * space)) / 6.0 :  (size.width - (2 * space)) / 3.0
        flowLayout.minimumLineSpacing = 2.0
        flowLayout.minimumInteritemSpacing = 2.0
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Flickr.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionCellViewController
        //download the image and get the data
        
        Flickr.getImageData(Flickr.photos[indexPath.row]) { (data, error) in
            if data != nil {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    let downloadedImage = data
                    cell.photoView.image = downloadedImage
                }
            } else {
                print("bad data of image nothing returned")
            }
        }
        return cell
    }
    
}