//
//  CounterView.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import SwiftUI

struct CounterView: View {
    @ObservedObject var state: AppState
    @State var isPrimeSheetShown: Bool = false
    @State var nthPrimeAlertShown: Bool = false
    @State var nthPrime: Int?

    var body: some View {
        VStack {
            HStack {
                Button {
                    state.count -= 1
                } label: {
                    Text("-")
                }
                Text("\(state.count)")
                Button {
                    state.count += 1
                } label: {
                    Text("+")
                }
            }
            Button {
                isPrimeSheetShown = true
            } label: {
                Text("Is this prime?")
            }
            Button {
                Composable_SwiftUI_App.nthPrime(state.count) { optionalPrime in
                    guard let prime = optionalPrime else {
                        return
                    }
                    
                    print(prime)
                    
                    nthPrime = prime
                    nthPrimeAlertShown = true
                }
            } label: {
                Text("What is the \(ordinal(state.count)) prime?")
            }
        }
        .font(.title)
        .navigationTitle("Counter Demo")
        .sheet(isPresented: $isPrimeSheetShown) {
            // onDismiss
        } content: {
            IsPrimeSheetView(state: state)
        }
        .alert("nth Prime", isPresented: $nthPrimeAlertShown) {
            Text("Ok")
        } message: {
            // the Text below gets build even before the alert is shown
            // can't have nthPrime! otherwise... crashes...
            Text("The \(ordinal(state.count)) prime is \(nthPrime ?? 0)")
        }

    }
}
