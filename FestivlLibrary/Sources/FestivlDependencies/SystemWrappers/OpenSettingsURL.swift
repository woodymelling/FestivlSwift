//
//  File.swift
//  
//
//  Created by Woodrow Melling on 7/23/23.
//

import Foundation
import UIKit
import Dependencies

struct OpenSettingsURLStringDependencyKey: DependencyKey {
    static var testValue: String = unimplemented("openSettingsURLString")
    static var liveValue: String = UIApplication.openSettingsURLString
}

extension DependencyValues {
    public var openSettingsURL: URL? {
        get { URL(string: self[OpenSettingsURLStringDependencyKey.self]) }
    }
}
