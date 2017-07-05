//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Dmytro Pasinchuk on 03.07.17.
//  Copyright © 2017 Dmytro Pasinchuk. All rights reserved.
//

import Foundation

class SearchResult {
    var name = ""
    var artistName = ""
    var artworkSmallURL = ""
    var artworkLargeURL = ""
    var storeURL = ""
    var kind = ""
    var currency = ""
    var price = 0.0
    var genre = ""
    
    static func < (left: SearchResult, right: SearchResult) -> Bool {
        return left.name.localizedStandardCompare(right.name) == .orderedAscending
    }
    static func > (left: SearchResult, right: SearchResult) -> Bool {
        return left.name.localizedStandardCompare(right.name) == .orderedDescending
    }
}
