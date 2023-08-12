//
//  File.swift
//  
//
//  Created by Woody on 2/10/22.
//

import Foundation

public protocol Searchable {
    var searchTerms: [String] { get }
}

public extension Collection where Element: Searchable {
    func filterForSearchTerm(_ searchText: String) -> [Element] {
        filterForSearchTerm(searchText, terms: \.searchTerms)
    }
}

public extension Collection {
    func filterForSearchTerm(_ searchText: String, terms: (Element) -> [String]) -> [Element] {
        guard !searchText.isEmpty else { return Array(self) }

        return self.filter { element in
            terms(element).contains {
                $0.lowercased().contains(searchText.lowercased())
            }
        }
    }
}
