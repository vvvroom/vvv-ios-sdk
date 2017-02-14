//
//  VVVAPIParameter.swift
//  VVV
//
//  Created by James Swiney on 14/2/17.
//  Copyright © 2017 James Swiney. All rights reserved.
//

import Foundation

enum VVVAPIParameter {
    case json,url
    
    func encode(URLRequest: URLRequest,parameters: [String: Any]?) -> (URLRequest, NSError?) {
        var mutableURLRequest = URLRequest
        
        guard let parameters = parameters else { return (mutableURLRequest, nil) }
        
        var encodingError: NSError? = nil
        
        switch self {
        case .url:
            
            func query(parameters: [String: Any]) -> String {
                var components: [(String, String)] = []
                
                for key in parameters.keys.sorted() {
                    let value = parameters[key]!
                    components += queryComponents(key:key,value: value)
                }
                return (components.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
            }
            
            
            if var urlComp = URLComponents(url: mutableURLRequest.url!, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                let percentEncodedQuery = (urlComp.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters: parameters)
                urlComp.percentEncodedQuery = percentEncodedQuery
                mutableURLRequest.url = urlComp.url
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
    
    
    func queryComponents(key: String,value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary.enumerated() {
                components += queryComponents(key: "\(key)[\(nestedKey)]", value: value as Any)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(key: "\(key)[]", value: value as Any)
            }
        } else {
            components.append((escape(string: key), escape(string:"\(value)")))
        }
        
        return components
    }
    
    func escape(string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = NSMutableCharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        
        var escaped = ""
        
        escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        
        return escaped
    }
}
