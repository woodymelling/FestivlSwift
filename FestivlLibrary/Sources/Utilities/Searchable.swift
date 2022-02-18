//
//  File.swift
//  
//
//  Created by Woody on 2/10/22.
//

import Foundation
import ComposableArchitecture

public protocol Searchable {
    var searchTerms: [String] { get }
}

public extension IdentifiedArray where Element: Searchable {
    func filterForSearchTerm(_ searchTerm: String) -> Self {

        guard !searchTerm.isEmpty else { return self }

        let lowerCaseSearchTerm = searchTerm.lowercased()

        return self.filter { element in
            element.searchTerms.contains {
                $0.lowercased().contains(lowerCaseSearchTerm)
            }
        }
    }
}
