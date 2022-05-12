//
//  AppState.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import Foundation
import FileProvider
import SwiftUI

/*
 
   https://developer.apple.com/documentation/combine/observableobject
   https://developer.apple.com/forums/thread/127243
   https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-observedobject-to-manage-state-from-external-objects
   https://www.hackingwithswift.com/quick-start/swiftui/what-is-the-published-property-wrapper
   https://developer.apple.com/documentation/combine/published

 */

final class Store<Value, Action>: ObservableObject {
    @Published private(set) var value: Value
    private let reducer: (inout Value, Action) -> Void
    
    init(initialValue: Value, reducer:  @escaping (inout Value, Action) -> Void) {
        self.value = initialValue
        self.reducer = reducer
    }
    
    func send(action: Action) {
        reducer(&value, action)
    }
}

// combine
func combine<Value, Action>(
  reducers: [(inout Value, Action) -> Void]
) -> (inout Value, Action) -> Void {
    { value, action in
        reducers.forEach { reducer in
            reducer(&value, action)
        }
    }
}

// pullback
func pullback<GlobalValue, LocalValue, GlobalAction, LocalAction>(
    reducer: @escaping (inout LocalValue, LocalAction) -> Void,
    valueKeyPath: WritableKeyPath<GlobalValue, LocalValue>,
    actionKeyPath: KeyPath<GlobalAction, LocalAction?>
) -> (inout GlobalValue, GlobalAction) -> Void {
    { (globalValue, globalAction) in
        guard
            let localAction = globalAction[keyPath: actionKeyPath]
        else {
            return
        }
        
        reducer(&globalValue[keyPath: valueKeyPath], localAction)
    }
}

// States
struct FavoritePrimesState {
    var favoritePrimes: [Int]
    var activityFeed: [AppState.Activity]
}

struct AppState {
    var count = 0
    var savedPrimes: [Int] = []
    var loggedInUser: User? = nil
    var activityFeed: [Activity] = []
    
    var favoritePrimesState: FavoritePrimesState {
        get {
            return FavoritePrimesState(
                favoritePrimes: savedPrimes,
                activityFeed: activityFeed
            )
        }
        set {
            savedPrimes = newValue.favoritePrimes
            activityFeed = newValue.activityFeed
        }
    }
        
    struct Activity {
        let timestamp: Date
        let type: ActivityType
        
        enum ActivityType {
            case addedFavoritePrime(Int)
            case removedFavoritePrime(Int)
        }
    }
    
    struct User {
        let id: Int
        let name: String
        let bio: String
    }
}

// Actions

enum CounterAction {
    case decrTapped
    case incrTapped
}

enum PrimeModalAction {
    case saveFavoritePrimeTapped
    case removeFavoritePrimeTapped
}

enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
}

enum AppAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
    case favoritePrimes(FavoritePrimesAction)
    
    var counterAction: CounterAction? {
        guard
            case let .counter(action) = self
        else {
            return nil
        }
        
        return action
    }
    
    var primeModalAction: PrimeModalAction? {
        guard
            case let .primeModal(action) = self
        else {
            return nil
        }
        
        return action
    }
    
    var favoritePrimes: FavoritePrimesAction? {
        guard
            case let .favoritePrimes(action) = self
        else {
            return nil
        }
        
        return action
    }
}

// Reducers

func completeLocalCounterReducer(value: inout Int, action: CounterAction) {
    switch action {
    case .decrTapped:
        value -= 1
    case .incrTapped:
        value += 1
    }
}

func actionLocalPrimeModalReducer(value: inout AppState, action: PrimeModalAction) {
    switch action {
    case .saveFavoritePrimeTapped:
        value.savedPrimes.append(value.count)
    case .removeFavoritePrimeTapped:
        value.savedPrimes.removeAll {
            $0 == value.count
        }
    }
}

func completeLocalFavoritePrimesReducer(value: inout FavoritePrimesState, action: FavoritePrimesAction) {
    switch action {
    case .deleteFavoritePrimes(let indexSet):
        for index in indexSet {
            value.favoritePrimes.remove(at: index)
        }
    }
}

let counterReducerV3 = pullback(
    reducer: completeLocalCounterReducer(value:action:),
    valueKeyPath: \AppState.count,
    actionKeyPath: \AppAction.counterAction
)
let primeModalReducer = pullback(
    reducer: actionLocalPrimeModalReducer(value:action:),
    valueKeyPath: \AppState.self,
    actionKeyPath: \AppAction.primeModalAction
)
let favoritePrimeReducer = pullback(
    reducer: completeLocalFavoritePrimesReducer(value:action:),
    valueKeyPath: \AppState.favoritePrimesState,
    actionKeyPath: \AppAction.favoritePrimes
)

// higher order reducers AKA wrappers?

func activityFeed(
    _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    return { value, action in
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

let combined = combine(
    reducers: [
        counterReducerV3,
        primeModalReducer,
        favoritePrimeReducer,
    ]
)
let appReducer = activityFeed(combined)
