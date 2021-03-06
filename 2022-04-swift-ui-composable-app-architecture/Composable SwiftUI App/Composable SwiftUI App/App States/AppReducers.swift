//
//  AppReducers.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 20/5/2022.
//

import Foundation
import ComposableArchitecture

import Counter
import FavoritePrimes
import PrimeModal

// Reducers

let counterReducerV3 = ReducerTypeBox.pullback(
    reducer: counterReducer(value:action:),
    writableValueKeyPath: \AppState.count,
    readableActionKeyPath: \AppAction.counterAction
)
let primeModalReducer = ReducerTypeBox.pullback(
    reducer: primeModalReducer(value:action:),
    writableValueKeyPath: \AppState.primeModal,
    readableActionKeyPath: \AppAction.primeModalAction
)
let favoritePrimeReducer = ReducerTypeBox.pullback(
    reducer: favoritePrimesReducer(value:action:),
    writableValueKeyPath: \AppState.savedPrimes,
    readableActionKeyPath: \AppAction.favoritePrimes
)

// higher order reducers AKA wrappers?

func activityFeed(
    wrapping reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    { value, action in
        switch action {
        case .counter:
            break
            
        case .primeModal(.removeFavoritePrimeTapped):
            value.activityFeed.append(
                .init(timestamp: Date(), type: .removedFavoritePrime(value.count))
            )
            
        case .primeModal(.saveFavoritePrimeTapped):
            value.activityFeed.append(
                .init(timestamp: Date(), type: .addedFavoritePrime(value.count))
            )
            
        case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
                value.activityFeed.append(
                    .init(timestamp: Date(), type: .removedFavoritePrime(value.savedPrimes[index]))
                )
            }
        }
        
        reducer(&value, action)
    }
}

func logging<Value, Action>(
    wrapping reducer: @escaping (inout Value, Action) -> Void
) -> (inout Value, Action) -> Void {
    { value, action in
        print("Before Action, State:")
        dump(value)
        print("Action: \(action)")
        
        reducer(&value, action)
        
        print("After Action, State:")
        dump(value)
        print("---")
    }
}

let combined = ReducerTypeBox.combine(
    reducers: [
        counterReducerV3,
        primeModalReducer,
        favoritePrimeReducer,
    ]
)

let appReducer = ReducerTypeBox<AppState, AppAction>.wrapping(
    reducer: combined,
    with: [
        logging(wrapping:),
        activityFeed(wrapping:),
    ]
)
