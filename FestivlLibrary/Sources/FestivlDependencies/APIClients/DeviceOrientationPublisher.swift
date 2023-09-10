//
//  File.swift
//  
//
//  Created by Woodrow Melling on 12/23/22.
//

import Foundation
import Dependencies
import Combine
import UIKit

public enum DeviceOrientation {
    case portrait
    case landscape

    static func deviceOrientationPublisher() -> AnyPublisher<DeviceOrientation, Never> {

        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .compactMap { ($0.object as? UIDevice)?.orientation }
            .compactMap { deviceOrientation -> DeviceOrientation? in
                if deviceOrientation.isPortrait {
                    return .portrait
                } else if deviceOrientation.isLandscape {
                    return .landscape
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()

    }
}

private enum DeviceOrientationKey: DependencyKey {
    public static let liveValue = DeviceOrientation.deviceOrientationPublisher()
}

public extension DependencyValues {
    var deviceOrientationPublisher: AnyPublisher<DeviceOrientation, Never> {
        get { self[DeviceOrientationKey.self] }
        set { self[DeviceOrientationKey.self] = newValue }
    }
}
