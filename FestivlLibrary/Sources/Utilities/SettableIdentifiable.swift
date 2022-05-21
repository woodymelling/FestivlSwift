//
//  File.swift
//  
//
//  Created by Woodrow Melling on 5/14/22.
//

import Foundation


public protocol SettableIdentifiable: Identifiable {
    var id: ID { get set }
}
