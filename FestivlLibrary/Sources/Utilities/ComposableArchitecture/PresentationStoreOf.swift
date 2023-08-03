//
//  PresentationStoreOf.swift
//  
//
//  Created by Woodrow Melling on 7/27/23.
//

import Foundation
import ComposableArchitecture

public typealias PresentationStoreOf<R: Reducer> = Store<PresentationState<R.State>, PresentationAction<R.Action>>
