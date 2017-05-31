//
//  SearchResult.swift
//  VVV
//
//  Created by James Swiney on 17/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/** The response object from the search request. Contains an array of search results (vehicles) and the depot pair for the results. */
public class SearchResponse {
    
    /** The pair of depots to pickup up and return the search results to. */
    public let depots : DepotPair
    
    /** The array of search results (vehicles) for the supplier and depot pair. */
    public let results : [SearchResult]
    
    /**
     
     Standard mapping init method for the search request
     
     - Parameters:
     - json: The json object for the search request
     - depots: The depotPair for the search request.
     
     */
    init?(json:[String:[String:Any]],depots:DepotPair) {
        
        var mapped = [SearchResult]()
        
        for (_,object) in json {
            guard let result = SearchResult(json: object,supplier: depots.supplier) else { continue }
            mapped.append(result)
        }
        
        self.depots = depots
        self.results = mapped
        
    }
    
}
