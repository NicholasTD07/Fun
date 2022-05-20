//
//  Counter.swift
//  Counter
//
//  Created by Nicholas The Personal on 20/5/2022.
//

import Foundation

public enum CounterAction {
    case decrTapped
    case incrTapped
}

public func counterReducer(value: inout Int, action: CounterAction) {
    switch action {
    case .decrTapped:
        value -= 1
    case .incrTapped:
        value += 1
    }
}

