//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by Nicholas The Personal on 20/5/2022.
//

import Foundation

public typealias PrimeModalState = (count: Int, savedPrimes: [Int])

public enum PrimeModalAction {
    case saveFavoritePrimeTapped
    case removeFavoritePrimeTapped
}

public func primeModalReducer(value: inout PrimeModalState, action: PrimeModalAction) {
    switch action {
    case .saveFavoritePrimeTapped:
        value.savedPrimes.append(value.count)
    case .removeFavoritePrimeTapped:
        value.savedPrimes.removeAll {
            $0 == value.count
        }
    }
}

