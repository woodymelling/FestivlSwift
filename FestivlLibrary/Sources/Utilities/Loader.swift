//
//  Loader.swift
//  
//
//  Created by Woodrow Melling on 8/19/23.
//

import Foundation

public enum Loader<Element> {
    case loading
    case loaded(Element)
}

public extension Loader {
    var loaded: Element? {
        switch self {
        case let .loaded(element): element
        case .loading: nil
        }
    }

    func map<T>(_ transform: (Element) throws -> T) rethrows -> Loader<T> {
        switch self {
        case .loading: .loading
        case .loaded(let element): .loaded(try transform(element))
        }
    }
}

extension Loader: Equatable where Element: Equatable {}
