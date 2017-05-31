//
//  VVVAPIParameter.swift
//  VVV
//
//  Created by James Swiney on 14/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation


/**
 This parameter encoding is mostly taken from the Alamofire Project created by `Alamofire Software Foundation` due to the fact that it
 works really well.  This enum provides 2 options
 
 - json: Encodes the params to json format and attaches them to the body of the request (typically used for POST method)
 - url: url encodes the params and appends them to the url.

 */
enum APIParameter {
    case json,url
    
    /**
     
     Encodes the provided parameters and attaches them to the URLRequest provided.
     
     - Parameters:
        - URLRequest: The urlRequest to attach the encoded parameters to.
        - parameters: A dictionary representation of the parameters to encode.
     - Return:
        - Tuple: A tuple of the urlRequest given in the parameters and any error that may have occured during the encoding.
     
     */
    func encode(URLRequest: URLRequest,parameters: [String: Any]?) -> (URLRequest, NSError?) {
        var mutableURLRequest = URLRequest
        
        guard let parameters = parameters else { return (mutableURLRequest, nil) }
        
        var encodingError: NSError? = nil
        
        switch self {
        case .url:
            if var urlComponents = URLComponents(url: mutableURLRequest.url!, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
                urlComponents.percentEncodedQuery = percentEncodedQuery
                mutableURLRequest.url = urlComponents.url
            }
            
        case .json:
            do {
                let options = JSONSerialization.WritingOptions()
                let data = try JSONSerialization.data(withJSONObject: parameters, options: options)
                
                if mutableURLRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                    mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                
                mutableURLRequest.httpBody = data
            } catch {
                encodingError = error as NSError
            }
        }
        
        return (mutableURLRequest, encodingError)
    }
    
    
    func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    /// Creates percent-escaped, URL encoded query string components from the given key-value pair using recursion.
    ///
    /// - parameter key:   The key of the query component.
    /// - parameter value: The value of the query component.
    ///
    /// - returns: The percent-escaped, URL encoded query string components.
    
    public func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }
    
    /// Returns a percent-escaped string following RFC 3986 for a query string key or value.
    ///
    /// RFC 3986 states that the following characters are "reserved" characters.
    ///
    /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
    /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
    ///
    /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
    /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
    /// should be percent-escaped in the query string.
    ///
    /// - parameter string: The string to be percent-escaped.
    ///
    /// - returns: The percent-escaped string.
    
    public func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        var escaped = ""
        
        //==========================================================================================================
        //
        //  Batching is required for escaping due to an internal bug in iOS 8.1 and 8.2. Encoding more than a few
        //  hundred Chinese characters causes various malloc error crashes. To avoid this issue until iOS 8 is no
        //  longer supported, batching MUST be used for encoding. 
        //==========================================================================================================
        
        if #available(iOS 8.3, *) {
            escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        } else {
            let batchSize = 50
            var index = string.startIndex
            
            while index != string.endIndex {
                let startIndex = index
                let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
                let range = startIndex..<endIndex
                
                let substring = string.substring(with: range)
                
                escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? substring
                
                index = endIndex
            }
        }
        
        return escaped
    }
}
