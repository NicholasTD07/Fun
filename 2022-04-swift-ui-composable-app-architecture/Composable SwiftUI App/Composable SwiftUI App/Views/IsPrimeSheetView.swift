//
//  IsPrimeSheetView.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import SwiftUI

struct IsPrimeSheetView: View {
    @ObservedObject var store: Store<AppState, CounterAction>

    var body: some View {
        if isPrime(store.value.count) {
            Text("\(store.value.count) is prime! 🎉")
            
            if store.value.savedPrimes.contains(store.value.count) {
                Button {
                    store.value.savedPrimes.removeAll {
                        $0 == store.value.count
                    }
                } label: {
                    Text("Remove from favorite primes...")
                }
            } else {
                Button {
                    store.value.savedPrimes.append(store.value.count)
                } label: {
                    Text("Save to favorite primes!")
                }
            }

        } else {
            Text("\(store.value.count) is not prime! 🙁")
        }
    }
}

struct IsPrimeSheetView_Previews: PreviewProvider {
    static var previews: some View {
        IsPrimeSheetView(
            store:
                Store(
                    initialValue: AppState(),
                    reducer: counterReducer
                )
        )
    }
}
