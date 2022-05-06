//
//  CounterView.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import SwiftUI

struct CounterView: View {
    @ObservedObject var state: AppState
    
    @State var nthPrime: Int?

    @State var isPrimeSheetShown = false
    @State var nthPrimeAlertShown = false
    @State var isNthPrimeDisabled = false

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
                isNthPrimeDisabled = true
                Composable_SwiftUI_App.nthPrime(state.count) { optionalPrime in
                    guard let prime = optionalPrime else {
                        return
                    }
                    
                    print(prime)
                    
                    nthPrime = prime
                    nthPrimeAlertShown = true
                    isNthPrimeDisabled = false
                }
            } label: {
                Text("What is the \(ordinal(state.count)) prime?")
            }
            .disabled(isNthPrimeDisabled)
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

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(state: AppState())
    }
}
