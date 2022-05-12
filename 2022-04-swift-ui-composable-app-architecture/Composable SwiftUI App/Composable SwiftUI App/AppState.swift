//
//  AppState.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import Foundation
import FileProvider

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

func combine<Value, Action>(
  _ first: @escaping (inout Value, Action) -> Void,
  _ second: @escaping (inout Value, Action) -> Void
) -> (inout Value, Action) -> Void {
    { value, action in
        first(&value, action)
        second(&value, action)
    }
}

func combine<Value, Action>(
  reducers: [(inout Value, Action) -> Void]
) -> (inout Value, Action) -> Void {
    { value, action in
        reducers.forEach { reducer in
            reducer(&value, action)
        }
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
//func pullback<LocalValue, GlobalValue, Action> (
//    reducer: @escaping (LocalValue, Action) -> LocalValue,
//    get: @escaping (GlobalValue) -> LocalValue,
//    set: @escaping (inout GlobalValue, LocalValue) -> Void
//) -> (inout GlobalValue, Action) -> Void {
//    { globalValue, action in
//        let localValue = get(globalValue)
//
//        let updated = reducer(localValue, action)
//
//        set(&globalValue, updated)
//    }
//}

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


func pullback<LocalValue, GlobalValue, Action> (
    reducer: @escaping (inout LocalValue, Action) -> Void,
    keyPath: WritableKeyPath<GlobalValue, LocalValue>
) -> (inout GlobalValue, Action) -> Void {
    { (globalValue, action) in
        reducer(&globalValue[keyPath: keyPath], action)
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

struct FavoritePrimesState {
    var favoritePrimes: [Int]
    var activityFeed: [AppState.Activity]
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
            savedPrimes = newValue.activityFeed
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
}

func counterReducer(state: inout AppState, action: CounterAction) {
    switch action {
    case .decrTapped:
        state.count -= 1
    case .incrTapped:
        state.count += 1
    }
    
}

func appReducer(value: inout AppState, action: AppAction) -> Void {
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
