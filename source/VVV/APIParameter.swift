//
//  VVVAPIParameter.swift
//  VVV
//
//  Created by James Swiney on 14/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation


/**
 This parameter encoding enum provides 2 options
 
 - json: Encodes the params to json format and attaches them to the body of the request (typically used for POST method)
 - url: url encodes the params and appends them to the url.

 */
enum APIParameter {
    case json,url
    
    /**
     
     Encodes the provided parameters and attaches them to the URLRequest provided.
     
     - Parameters:
     - APIRequest: The apiRequest to encode
     - Return:
     - URLRequest?: A url request to use in the session, will be nil if building the url or params fails
     
     */
    static func encode(networkRequest:APIRequest) -> URLRequest? {
        
        //Create URL
        guard let urlPath = buildUrlFrom(request: networkRequest),
            var url = URL(string: urlPath) else { return nil }
        
        //If encoding is URL query create URL query params
        if networkRequest.encoding() == .url {
            guard var comps = URLComponents(string: urlPath) else { return nil }
            var queryItems = [URLQueryItem]()
            for (key, value) in networkRequest.params() {
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
            comps.queryItems = queryItems
            guard let compUrl = comps.url else { return nil }
            url = compUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = networkRequest.method().rawValue
        
        //Add headers
        for (key, value) in networkRequest.headers() {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        
        //If encoding is JSON create JSON Post Body params
        if networkRequest.encoding() == .json {
            do {
                let options = JSONSerialization.WritingOptions()
                let data = try JSONSerialization.data(withJSONObject: networkRequest.params(), options: options)
                
                if request.value(forHTTPHeaderField: "Content-Type") == nil {
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                
                request.httpBody = data
            } catch {
                return nil
            }
        }
        return request
    }
    
    /**
     
     This builds the url to perform from the API request.  It appends any required strings and the percent encodes the url for safety from illegal characters. Note this happens BEFORE any urlencoded "GET" parameters are appended to the url.
     
     - Parameters:
     - request: The apiRequest to get the url information from
     
     - Return:
     - String: The percent encoded url.
     
     */
    static func buildUrlFrom(request:APIRequest) -> String? {
        let url = "\(request.endPoint().fullUrl())\(request.appendToUrl())"
        
        if let safeUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            return safeUrl
        }
        
        return nil
    }
}
