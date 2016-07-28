//
//  Constants.swift
//  virtualTourist
//
//  Created by Anna Rogers on 7/27/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit

struct Constants {
//    safe_search=1&extras=url_m&bbox=-123.4194,36.7749,-121.4194,38.7749&api_key=321b0c2c23c0824823d30ff54f120380&method=flickr.photos.search&format=json&nojsoncallback=1
    
    struct FlickrParameterKeys {
        static let SafeSearch = "safe_search"
        static let Extras = "extras"
        static let BoundingBox = "bbox"
        static let APIKey = "api_key"
        static let Method = "method"
        static let Format = "format"
        static let NoJsonCallback = "nojsoncallback"
    }
    
    struct FlickrParameterValues {
        static let SafeSearch = "1"
        static let Extras = "url_m"
        static let APIKey = "321b0c2c23c0824823d30ff54f120380"
        static let Method = "flickr.photos.search"
        static let Format = "json"
        static let NoJsonCallback = "1"
    }
    
    struct Flickr {
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
}