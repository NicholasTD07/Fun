//
//  IsPrimeSheetView.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import SwiftUI

struct IsPrimeSheetView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        
        if isPrime(state.count) {
            Text("\(state.count) is prime! 🎉")
            
            if state.savedPrimes.contains(state.count) {
                Button {
                    state.savedPrimes.removeAll {
                        $0 == state.count
                    }
                } label: {
                    Text("Remove from favorite primes...")
                }
            } else {
                Button {
                    state.savedPrimes.append(state.count)
                } label: {
                    Text("Save to favorite primes!")
                }
            }

        } else {
            Text("\(state.count) is not prime! 🙁")
        }
    }
}
