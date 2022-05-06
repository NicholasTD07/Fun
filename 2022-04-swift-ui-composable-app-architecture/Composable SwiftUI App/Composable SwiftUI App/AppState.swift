//
//  AppState.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import Foundation

/*
 
   https://developer.apple.com/documentation/combine/observableobject
   https://developer.apple.com/forums/thread/127243
   https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-observedobject-to-manage-state-from-external-objects
   https://www.hackingwithswift.com/quick-start/swiftui/what-is-the-published-property-wrapper
   https://developer.apple.com/documentation/combine/published

 */

final class Store<Value, Action>: ObservableObject {
    @Published var value: Value
    private let reducer: (inout Value, Action) -> Void
    
    init(initialValue: Value, reducer:  @escaping (inout Value, Action) -> Void) {
        self.value = initialValue
        self.reducer = reducer
    }
    
    func send(action: Action) {
        reducer(&value, action)
    }
}

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
