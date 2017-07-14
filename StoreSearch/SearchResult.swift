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
    
    private let displayNamesForKind = [
    "album": NSLocalizedString("Album", comment: "Localized kind: Album"),
    "audiobook": NSLocalizedString("Audio Book", comment: "Localized kind: Audio Book"),
    "book": NSLocalizedString("Book", comment: "Localized kind: Book"),
    "ebook": NSLocalizedString("E-book", comment: "Localized kind: E-book"),
    "feature-movie": NSLocalizedString("Movie", comment: "Localized kind: Movie"),
    "music-video": NSLocalizedString("Music Video", comment: "Localized kind: Music Video"),
    "podcast": NSLocalizedString("Podcast", comment: "Localized kind: Podcast"),
    "software": NSLocalizedString("App", comment: "Localized kind: App"),
    "song": NSLocalizedString("Song", comment: "Localized kind: Song"),
    "tv-episode": NSLocalizedString("TV Episode", comment: "Localized kind: TV Episode")
    ]
    
    static func < (left: SearchResult, right: SearchResult) -> Bool {
        return left.name.localizedStandardCompare(right.name) == .orderedAscending
    }
    static func > (left: SearchResult, right: SearchResult) -> Bool {
        return left.name.localizedStandardCompare(right.name) == .orderedDescending
    }
    
    func kindForDisplay() -> String {
        return displayNamesForKind[kind] ?? kind
    }

}
