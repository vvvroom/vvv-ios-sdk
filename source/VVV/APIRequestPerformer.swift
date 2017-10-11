//
//  VVVAPIRequestPerformer.swift
//  VVV
//
//  Created by James Swiney on 13/12/16.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/**
The API request method currently only POST and GET are being used
 
 - post: POST method (defaults encoding to json)
 - get: GET method (defaults to url encoding)
 - put: PUT method
 */
enum APIMethod : String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
}

/** A protocol to be added to any object or view that needs to perform network requests */
protocol APIRequestPerformer {
    
}

/** The extension containing protocol methods */
extension APIRequestPerformer {
    
    /**
     
     Primary method to be called, will perform a APIRequest on the default APIClient urlSession
     
     - Parameters:
        - apiRequest: The apiRequest to be performed callback will occur on the apiRequest responseHandler
     
     */
    func perform(apiRequest:APIRequest) {
        self.perform(urlSession: APIClient.shared.urlSession, apiRequest: apiRequest)
    }
    
    /**
     
     Performs a dataTask to process the apiRequest on the provided urlSession and converts the response to JSON and calls the responseHandler of the apiRequest.
     
     - Parameters:
        - urlSession: The urlSession to perform the request on.
        - apiRequest: The APIRequest to perform.
     
     */
    func perform(urlSession:URLSession,apiRequest:APIRequest) {
        
        if APIClient.shared.status != .ready && apiRequest.endPoint() != .Details {
            apiRequest.responseHandler()(nil, "API Client is not ready yet, please wait for VVVAPIClientStatusReadyNotification to be called or move your APIClient.setupWith method to the appdelegate didFinishLaunchingWithOptions to ensure it is ready when you need to perform requests")
            return
        }
        
        guard let request = APIParameter.encode(networkRequest: apiRequest) else {
            apiRequest.responseHandler()(nil, "Something went wrong, Error encoding parameters")
            return
        }

        let task = urlSession.dataTask(with: request) { (data, response, error) in
            
            //Dispatch to main thread for UI updates
            DispatchQueue.main.async {
                
                self.log(request: request, data: data)
                
                guard let json = Utils.convertDataToJson(data: data) else {
                    
                    if let error = error {
                        apiRequest.responseHandler()(nil, error.localizedDescription)
                        return
                    }
                    apiRequest.responseHandler()(nil, "Request failed with no error")
                    return
                }
                
                apiRequest.responseHandler()(json,nil)
            }
        }
        task.resume()
    }
    
    func log(request:URLRequest,data:Data?) {
        
        print("request url \(request.url!)")
        if let body = request.httpBody {
            print("request body \(String(data: body, encoding: .utf8)!)")
        }
        
        if let headers = request.allHTTPHeaderFields {
            print("request headers \(headers)")
        }
        
        guard let data = data,
            let dataString = String(data: data, encoding: .utf8) else { return }
        print("response \(dataString)")
    }
}
