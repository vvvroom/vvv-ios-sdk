//
//  VVVAPIRequestPerformer.swift
//  VVV
//
//  Created by James Swiney on 13/12/16.
//  Copyright © 2016 James Swiney. All rights reserved.
//

import Foundation

enum VVVAPIMethod : String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
}

protocol VVVAPIRequestPerformer {
    
}

extension VVVAPIRequestPerformer {
    
    func buildUrlFrom(request:VVVAPIRequest) -> String? {
        let url = "\(request.endPoint().fullUrl())\(request.appendToUrl())"
        
        if let safeUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            return safeUrl
        }
        return nil
    }
    
    func perform(urlSession:URLSession,apiRequest:VVVAPIRequest) {
        
        guard let stringUrl = buildUrlFrom(request: apiRequest),
            let url = URL(string:stringUrl) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = apiRequest.method().rawValue
        let encodedResult = apiRequest.encoding().encode(URLRequest: request, parameters: apiRequest.params())
        request = encodedResult.0

        let task = urlSession.dataTask(with: request) { (data, response, error) in
            
            guard let json = self.convertDataToJson(data: data) else {
                if let error = error {
                    apiRequest.responseHandler()(nil, error.localizedDescription)
                    return
                }
                apiRequest.responseHandler()(nil, "Request failed with no error")
                return
            }
            
            apiRequest.responseHandler()(json,nil)
        }
        task.resume()
    }
    
    func convertDataToJson(data:Data?) -> Any? {
        
        guard let data = data else { return nil }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            return jsonObject
        } catch {
            print("failed to parse json")
            if let string = String(data: data, encoding: .utf8) {
                print("error dump \(string)")
            }
            return nil
        }
    }
    
}
