//
//  File.swift
//  
//
//  Created by Woodrow Melling on 8/30/23.
//

import Foundation
import ComposableArchitecture

extension _ReducerPrinter {
    public static func customDump(to printer: @escaping (String) -> Void) -> Self {
        Self { receivedAction, oldState, newState in
            var target = ""
            target.write("received action:\n")
            CustomDump.customDump(receivedAction, to: &target, indent: 2)
            target.write("\n")
            target.write(diff(oldState, newState).map { "\($0)\n" } ?? "  (No state changes)\n")

            printer(target)
        }
    }
}
