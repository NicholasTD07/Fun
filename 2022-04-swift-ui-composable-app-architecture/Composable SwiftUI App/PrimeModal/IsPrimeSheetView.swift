//
//  IsPrimeSheetView.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import SwiftUI

import ComposableArchitecture

public struct IsPrimeSheetView: View {
    @ObservedObject var store: Store<PrimeModalState, PrimeModalAction>

    public var body: some View {
        if isPrime(store.value.count) {
            Text("\(store.value.count) is prime! 🎉")
            
            if store.value.savedPrimes.contains(store.value.count) {
                Button {
                    store.send(
                        action: .removeFavoritePrimeTapped
                    )
                } label: {
                    Text("Remove from favorite primes...")
                }
            } else {
                Button {
                    store.send(
                        action: .saveFavoritePrimeTapped
                    )
                } label: {
                    Text("Save to favorite primes!")
                }
            }

        } else {
            Text("\(store.value.count) is not prime! 🙁")
        }
    }
    
    public init(store: Store<PrimeModalState, PrimeModalAction>) {
        self.store = store
    }
}

private func isPrime(_ n: Int) -> Bool {
    if n <= 1 {
        return false
    }
    if n <= 3 {
        return true
    }
    
    for i in 2...(Int(sqrtf(Float(n)))) {
        if n % i == 0 {
            return false
        }
    }
    
    return true
}

//struct IsPrimeSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        IsPrimeSheetView(
//            store:
//                Store(
//                    initialValue: AppState(),
//                    reducer: appReducer
//                )
//        )
//    }
//}
