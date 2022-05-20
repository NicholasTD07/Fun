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

// States

struct AppState {
    var count = 0
    var savedPrimes: [Int] = []
    var loggedInUser: User? = nil
    var activityFeed: [Activity] = []
        
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

func completeLocalFavoritePrimesReducer(value: inout [Int], action: FavoritePrimesAction) {
    switch action {
    case .deleteFavoritePrimes(let indexSet):
        for index in indexSet {
            value.remove(at: index)
        }
    }
}

enum ReducerTypeBox<Value, Action> {
    typealias Reducer = (inout Value, Action) -> Void
    typealias HigherOrderReducer = (@escaping Reducer) -> Reducer
    
    static func wrapping(
        reducer: @escaping Reducer,
        with higherOrderReducers: [HigherOrderReducer]
    ) -> Reducer {
        let wrapped = higherOrderReducers.reduce(reducer) { (reducer, higherOrderReducer) -> Reducer in
            higherOrderReducer(reducer)
        }
        
        return wrapped
    }

    static func combine(
      reducers: [(inout Value, Action) -> Void]
    ) -> (inout Value, Action) -> Void {
        { value, action in
            reducers.forEach { reducer in
                reducer(&value, action)
            }
        }
    }
    
    static func pullback<LocalValue, LocalAction>(
        reducer: @escaping (inout LocalValue, LocalAction) -> Void,
        writableValueKeyPath: WritableKeyPath<Value, LocalValue>,
        readableActionKeyPath: KeyPath<Action, LocalAction?>
    ) -> (inout Value, Action) -> Void {
        { (globalValue, globalAction) in
            guard
                let localAction = globalAction[keyPath: readableActionKeyPath]
            else {
                return
            }
            
            reducer(&globalValue[keyPath: writableValueKeyPath], localAction)
        }
    }
}


let counterReducerV3 = ReducerTypeBox.pullback(
    reducer: completeLocalCounterReducer(value:action:),
    writableValueKeyPath: \AppState.count,
    readableActionKeyPath: \AppAction.counterAction
)
let primeModalReducer = ReducerTypeBox.pullback(
    reducer: actionLocalPrimeModalReducer(value:action:),
    writableValueKeyPath: \AppState.self,
    readableActionKeyPath: \AppAction.primeModalAction
)
let favoritePrimeReducer = ReducerTypeBox.pullback(
    reducer: completeLocalFavoritePrimesReducer(value:action:),
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
