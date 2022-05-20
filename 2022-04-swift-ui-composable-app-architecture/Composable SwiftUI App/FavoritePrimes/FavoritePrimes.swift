//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Nicholas The Personal on 20/5/2022.
//

import Foundation

public enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
}

public func completeLocalFavoritePrimesReducer(value: inout [Int], action: FavoritePrimesAction) {
    switch action {
    case .deleteFavoritePrimes(let indexSet):
        for index in indexSet {
            value.remove(at: index)
        }
    }
}
