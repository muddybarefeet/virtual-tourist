//
//  FlickrClient.swift
//  virtualTourist
//
//  Created by Anna Rogers on 7/27/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit

class FlickrClient {
    
    static let sharedInstance = FlickrClient()
    private init() {}
    
//
    
    func getImagesForLocation (lat: Double, long: Double, completionHandlerForImages: (data: AnyObject?, error: String?) -> Void) {
        
        //pull together the various end points to make the request
        let baseUrl = "https://api.flickr.com/services/rest"
        
        let parameters: [String: String!] = [
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.SafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.Extras,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(lat, longitude: long),
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.Method,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.Format,
            Constants.FlickrParameterKeys.NoJsonCallback: Constants.FlickrParameterValues.NoJsonCallback
        ]
        
        let request = makeRequest(baseUrl, parameters: parameters)
        print("request", request)
        
        sendRequest(request) { (data, response, error) in
            print("recieve request sent")
            if (error != nil) {
                print("error", error)
                completionHandlerForImages(data: nil, error: error)
            } else {
                print("good response from request", data)
                completionHandlerForImages(data: data, error: nil)
            }
        }
        
    }
    
    //safe_search=1&extras=url_m&bbox=-123.4194,36.7749,-121.4194,38.7749&api_key=321b0c2c23c0824823d30ff54f120380&method=flickr.photos.search&format=json&nojsoncallback=1
    //method=flickr.photos.search&nojsoncallback=1&safe_search=1&extras=url_m&format=json&api_key=321b0c2c23c0824823d30ff54f120380
    
    private func bboxString (latitude: Double, longitude: Double) -> String {
        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    
    
    private func makeRequest (baseURL: String, parameters: [String:String!]) -> NSMutableURLRequest {
        print("make the request")
        //TODO: sent a random page number to got
        var newURL = baseURL + "?"
        var first = true;
        for (key, value) in parameters {
            let newParam = key + "=" + value
            if first == true {
                first = false
                newURL += newParam
            } else {
                newURL += "&" + newParam
            }
        }
        print("new URL--->", newURL)
        
        let request = NSMutableURLRequest(URL: NSURL(string: newURL)!)
        return request
        
    }
    
    private func sendRequest (request: NSMutableURLRequest, completionHandlerForRequest: (data: AnyObject?, response: NSHTTPURLResponse??, error: String?) -> Void) {
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            if error != nil {
                completionHandlerForRequest(data: nil, response: nil, error: "There was an error in the request response")
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForRequest(data: nil, response: nil, error: "The status code returned was not a OK")
                return
            }
            guard let data = data else {
                completionHandlerForRequest(data: nil, response: nil, error: "No data returned from the API")
                return
            }
            
            var parsedResult: AnyObject?
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                print("Could not parse the response to a readable format", parsedResult)
                completionHandlerForRequest(data: nil, response: (response as! NSHTTPURLResponse), error: "Could not parse the response to a readable format")
                return
            }
            print("json", parsedResult)
            completionHandlerForRequest(data: parsedResult, response: (response as! NSHTTPURLResponse), error: nil)
        }
        
        task.resume()
        
    }
        
}
    

    
    
    

