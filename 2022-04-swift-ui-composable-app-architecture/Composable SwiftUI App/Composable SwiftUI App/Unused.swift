//
//  Unused.swift
//  Composable SwiftUI App
//
//  Created by Nicholas Tian on 12/5/2022.
//

import Foundation

// Note: This file isn't included in any targets at all.

func combine<Value, Action>(
  _ first: @escaping (inout Value, Action) -> Void,
  _ second: @escaping (inout Value, Action) -> Void
) -> (inout Value, Action) -> Void {
    { value, action in
        first(&value, action)
        second(&value, action)
    }
}

func pullback<LocalValue, GlobalValue, Action> (
    reducer: @escaping (inout LocalValue, Action) -> Void,
    get: @escaping (GlobalValue) -> LocalValue,
    set: @escaping (inout GlobalValue, LocalValue) -> Void
) -> (inout GlobalValue, Action) -> Void {
    { globalValue, action in
        var localValue = get(globalValue)
        
        reducer(&localValue, action)
        
        set(&globalValue, localValue)
    }
}

// pullback but with immutable reducers
func pullback<LocalValue, GlobalValue, Action> (
    reducer: @escaping (LocalValue, Action) -> LocalValue,
    get: @escaping (GlobalValue) -> LocalValue,
    set: @escaping (inout GlobalValue, LocalValue) -> Void
) -> (inout GlobalValue, Action) -> Void {
    { globalValue, action in
        let localValue = get(globalValue)

        let updated = reducer(localValue, action)

        set(&globalValue, updated)
    }
}

func pullback<LocalValue, GlobalValue, Action> (
    reducer: @escaping (inout LocalValue, Action) -> Void,
    keyPath: WritableKeyPath<GlobalValue, LocalValue>
) -> (inout GlobalValue, Action) -> Void {
    { (globalValue, action) in
        reducer(&globalValue[keyPath: keyPath], action)
    }
}

func counterReducer(value: inout Int, action: AppAction) {
    switch action {
    case .counter(let counterAction):
        switch counterAction {
        case .decrTapped:
            return value -= 1
        case .incrTapped:
            return value += 1
        }
    case .primeModal:
        break
    case .favoritePrimes:
        break
    }
}

func test() {
    let reducer = pullback(
        reducer: counterReducer(value:action:),
        get: { (state: AppState) in state.count },
        set: { (state: inout AppState, value: Int) in state.count = value }
    )
    
    let keyPath = \AppState.count
    let states: [AppState] = []
    let mappedCount = states.map(\.count)
    
    let anotherReducer = pullback(
        reducer: counterReducer(value:action:),
        keyPath: keyPath
    )
    
    let combined = combine(reducers: [reducer])
}

func moreTest() {
    let reducers = [
        pullback(
            reducer: counterReducer(value:action:),
            keyPath: \AppState.count
        ),
        pullback(
            reducer: favoritePrimesReducer(value:action:),
            keyPath: \AppState.favoritePrimesState
        )
    ]
    
    let combined = combine(reducers: reducers)
}

func counterReducer(state: inout AppState, action: CounterAction) {
    switch action {
    case .decrTapped:
        state.count -= 1
    case .incrTapped:
        state.count += 1
    }
}

func favoritePrimesReducer(value: inout FavoritePrimesState, action: AppAction) {
    switch action {
    case .counter(let counterAction):
        break
    case .primeModal:
        break
    case .favoritePrimes(let favoritePrimeAction):
        switch favoritePrimeAction {
        case .deleteFavoritePrimes(let indexSet):
            
            for index in indexSet {
                let activity = AppState.Activity(
                    timestamp: Date(),
                    type: .removedFavoritePrime(
                        value.favoritePrimes[index]
                    )
                )

                value.activityFeed.append(activity)
                value.favoritePrimes.remove(at: index)
            }
        }
    }
}


func primeModalReducer(value: inout AppState, action: AppAction) -> Void {
    switch action {
    case .counter:
        break
    case .primeModal(.saveFavoritePrimeTapped):
        value.savedPrimes.append(value.count)
        
        value.activityFeed.append(
            .init(
                timestamp: Date(),
                type: .addedFavoritePrime(value.count)
            )
        )
    case .primeModal(.removeFavoritePrimeTapped):
        value.savedPrimes.removeAll {
            $0 == value.count
        }
        
        value.activityFeed.append(
            .init(
                timestamp: Date(),
                type: .removedFavoritePrime(value.count)
            )
        )
    case .favoritePrimes:
        break
    }
}

func appReducerOriginal(value: inout AppState, action: AppAction) -> Void {
    switch action {
    case .counter(.decrTapped):
        value.count -= 1
    case .counter(.incrTapped):
        value.count += 1
    case .primeModal(.saveFavoritePrimeTapped):
        value.savedPrimes.append(value.count)

        value.activityFeed.append(
            .init(
                timestamp: Date(),
                type: .addedFavoritePrime(value.count)
            )
        )
    case .primeModal(.removeFavoritePrimeTapped):
        value.savedPrimes.removeAll {
            $0 == value.count
        }

        value.activityFeed.append(
            .init(
                timestamp: Date(),
                type: .removedFavoritePrime(value.count)
            )
        )
    case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
        for index in indexSet {
            let prime = value.savedPrimes[index]

            value.savedPrimes.remove(at: index)

            value.activityFeed.append(
                .init(
                    timestamp: Date(),
                    type: .removedFavoritePrime(prime)
                )
            )
        }
    }
}
