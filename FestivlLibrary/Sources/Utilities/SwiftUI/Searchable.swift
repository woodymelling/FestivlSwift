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
    func filterForSearchTerm(_ searchTerm: String) -> [Element] {

        guard !searchTerm.isEmpty else { return Array(self) }

        return self.filter { element in
            element.searchTerms.contains {
                $0.lowercased().contains(searchTerm.lowercased())
            }
        }
    }
}