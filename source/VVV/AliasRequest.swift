//
//  ConfigRequest.swift
//  VVV
//
//  Created by James Swiney on 14/3/17.
//  Copyright © 2017 James Swiney. All rights reserved.
//

import UIKit

//Fetches the alias for the API Key, to identify requests.
class AliasRequest: APIRequest {

    /** completion block called after request with the site alias and an error message if failed */
    let completion : (String?,String?)->()
    
    /**
     
     Inits the request with completion block
     
     - Parameters:
     - completion: The block called after the request completes
     
     */
    init(completion:@escaping (String?,String?)->()) {
        self.completion = completion
    }

    override func endPoint() -> NetworkEndpoint {
        return .Details
    }
    
    override func method() -> APIMethod {
        return .get
    }
    
    override func encoding() -> APIParameter {
        return .url
    }
    
    override func responseHandler() -> NetworkResponseHandler {
        return {(response,error) -> Void in
            
            let mappedResponse = super.map(data: response as? Data, toClass: AliasResponse.self)
        
            if let alias = mappedResponse?.alias {
                self.completion(alias,nil)
                return
            }
            
            if let error = mappedResponse?.message {
                self.completion(nil,error)
                return
            }
            self.completion(nil,"An unknown error occured")
        }
    }
}

class AliasResponse : Decodable {
    
    let alias : String?
    let message : String?
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.message = try values.decodeIfPresent(String.self, forKey: .message)
        let container = try? values.nestedContainer(keyedBy: ClientCodingKeys.self, forKey: .client)
        self.alias = try container?.decodeIfPresent(String.self, forKey: .alias)
    }
    
    enum CodingKeys : String,CodingKey {
        case client
        case message
    }
    
    enum ClientCodingKeys : String,CodingKey {
        case alias
    }
}
