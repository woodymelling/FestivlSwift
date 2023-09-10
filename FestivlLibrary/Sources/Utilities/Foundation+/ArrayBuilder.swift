//
//  ArrayBuilder.swift
//  
//
//  Created by Woodrow Melling on 8/19/23.
//

import Foundation

@resultBuilder
public enum ArrayBuilder<Element> {
    public typealias Expression = Element

    public typealias Component = [Element]

    public static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }

    public static func buildExpression(_ expression: Expression?) -> Component {
        expression.map({ [$0] }) ?? []
    }

    public static func buildBlock(_ children: Component...) -> Component {
        children.flatMap({ $0 })
    }

    public static func buildOptional(_ children: Component?) -> Component {
        children ?? []
    }

    public static func buildPartialBlock(accumulated: ArrayBuilder<Element>.Component, next: ArrayBuilder<Element>.Component) -> ArrayBuilder<Element>.Component {
        return accumulated + next
    }

    public static func buildBlock(_ component: Component) -> Component {
        component
    }

    public static func buildEither(first child: Component) -> Component {
        child
    }

    public static func buildEither(second child: Component) -> Component {
        child
    }
}
