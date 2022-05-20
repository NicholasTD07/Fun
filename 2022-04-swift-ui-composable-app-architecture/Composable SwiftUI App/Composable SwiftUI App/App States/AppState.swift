//
//  AppState.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import Foundation
import FileProvider
import SwiftUI

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
