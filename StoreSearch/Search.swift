//
//  Search.swift
//  StoreSearch
//
//  Created by Dmytro Pasinchuk on 13.07.17.
//  Copyright © 2017 Dmytro Pasinchuk. All rights reserved.
//

import UIKit

typealias SearchComplete = (Bool) -> Void

class Search {
    private(set) var state: State = .nonSearchedYet //private only setter
    
    enum State {
        case nonSearchedYet
        case loading
        case noResult
        case results([SearchResult])
    }
    
    enum Category:Int {
        case all = 0
        case music = 1
        case software = 2
        case ebooks = 3
        
        var entityName: String {
            switch self {
            case .all: return ""
            case .music: return "musicTrack"
            case .software: return "software"
            case .ebooks: return "ebook"
            }
        }
    }
    
    private var dataTask: URLSessionDataTask? = nil
    
    func performSearch(for text: String, category: Category, completition: @escaping SearchComplete) {
        if !text.isEmpty {
            dataTask?.cancel()
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        state = .loading
            
        let url = iTunesURL(searchText: text, category: category)
            
        let session = URLSession.shared
        dataTask = session.dataTask(with: url) {data, response, error in
            self.state = .nonSearchedYet
            var success = false
            if let error = error as? NSError, error.code == -999 {
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let jsonData = data, let jsonDictionary = self.parse(json: jsonData) {
                        
                    var searchResults = self.parse(dictionary: jsonDictionary)
                    if searchResults.isEmpty {
                        self.state = .noResult
                    } else {
                        searchResults.sort(by: <)
                        self.state = .results(searchResults)
                    }
                    success = true
                }
            }
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completition(success)
            }
        }
        dataTask?.resume()
    }
    
    private func iTunesURL(searchText: String, category: Category) -> URL {
        
        let entityName = category.entityName
        
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=100&entity=%@", escapedSearchText, entityName)
        let url = URL(string: urlString)
        return url!
    }

    private func parse(json data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch  {
            print("JSON error: '\(error)'")
            return nil
        }
    }
    
    private func parse(dictionary: [String: Any]) -> [SearchResult] {
        guard let array = dictionary["results"] as? [Any] else {
            print("Expected 'results' array")
            return []
        }
        var searchResults = [SearchResult]()
        
        for resultDict in array {
            if let resultDict = resultDict as? [String: Any] {
                var searchResult: SearchResult?
                
                if let wrapperType = resultDict["wrapperType"] as? String {
                    switch wrapperType {
                    case "track":
                        searchResult = parse(track: resultDict)
                    case "audiobook":
                        searchResult = parse(audoobook: resultDict)
                    case "software":
                        searchResult = parse(software: resultDict)
                    default:
                        break
                    }
                } else if let kind = resultDict["kind"] as? String, kind == "ebook" {
                    searchResult = parse(ebook: resultDict)
                }
                
                if let result = searchResult {
                    searchResults.append(result)
                }
            }
        }
        return searchResults
    }
    
    private func parse(track dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
    }
    
    private func parse(audoobook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["collectionPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
    }
    
    private func parse(software dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
    }
    
    private func parse(ebook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        if let genres: Any = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joined(separator: ", ")
        }
        
        return searchResult
    }

}
