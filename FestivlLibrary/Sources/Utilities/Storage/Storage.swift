//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/21/22.
//

import Foundation



@propertyWrapper
public struct Storage<T, StorageType> {
    private let key: String
    private let defaultValue: T
    private let transformation: Transformation<T, StorageType>

    public struct Transformation<InType, OutType> {
        public init(get: @escaping (OutType) -> InType, set: @escaping (InType) -> OutType) {
            self.get = get
            self.set = set
        }

        var get: (OutType) -> InType
        var set: (InType) -> OutType
    }

    public init(key: String, defaultValue: T, transformation: Transformation<T, StorageType>) {
        self.key = key
        self.defaultValue = defaultValue
        self.transformation = transformation
    }

    public var wrappedValue: T {
        get {
            // Read value from UserDefaults
            return transformation.get(
                UserDefaults.standard.object(forKey: key) as? StorageType ?? transformation.set(defaultValue)
            )
        }
        set {
            UserDefaults.standard.set(transformation.set(newValue), forKey: key)
        }
    }
}


public extension Storage where T == StorageType {
    init(key: String, defaultValue: T) {
        self.init(
            key: key,
            defaultValue: defaultValue,
            transformation: .init(get: { $0 }, set: { $0 })
        )
    }
}

extension Storage: Equatable where T: Equatable {
    public static func == (lhs: Storage, rhs: Storage) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue

    }
}
