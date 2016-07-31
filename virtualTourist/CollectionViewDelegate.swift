//
//  CollectionViewDelegate.swift
//  virtualTourist
//
//  Created by Anna Rogers on 7/28/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//
//
//import UIKit
//
//class CollectionViewDelegate: NSObject, UICollectionViewDelegate {
//    
//    let Flickr = FlickrClient.sharedInstance
//    
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("in the collection", Flickr.photos.count)
//        return Flickr.photos.count
//    }
//    
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionCellViewController
//        //download the image and get the data
//        
//        Flickr.getImageData(Flickr.photos[indexPath.row]) { (data, error) in
//            if data != nil {
//                let downloadedImage = data
//                NSOperationQueue.mainQueue().addOperationWithBlock {
//                    cell.photoView.image = downloadedImage
//                }
//            } else {
//                print("bad data of image nothing returned")
//            }
//        }
//        return cell
//    }
//    
//}
