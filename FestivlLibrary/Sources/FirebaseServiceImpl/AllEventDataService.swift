//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/24/22.
//

import Foundation
import FestivlDependencies
import Dependencies

extension AllEventDataClientKey: DependencyKey {
    public static var liveValue = AllEventDataClient
}
