//
//  CounterView.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import SwiftUI
import ComposableArchitecture

typealias CounterViewState = (count: Int, savedPrimes: [Int])

struct CounterView: View {
    @ObservedObject var store: Store<CounterViewState, AppAction>

    @State var nthPrime: Int?

    @State var isPrimeSheetShown = false
    @State var nthPrimeAlertShown = false
    @State var isNthPrimeDisabled = false

    var body: some View {
        VStack {
            HStack {
                Button {
                    store.send(action: .counter(.decrTapped))
                } label: {
                    Text("-")
                }
                Text("\(store.value.count)")
                Button {
                    store.send(action: .counter(.incrTapped))
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
                Composable_SwiftUI_App.nthPrime(store.value.count) { optionalPrime in
                    guard let prime = optionalPrime else {
                        return
                    }
                    
                    print(prime)
                    
                    nthPrime = prime
                    nthPrimeAlertShown = true
                    isNthPrimeDisabled = false
                }
            } label: {
                Text("What is the \(ordinal(store.value.count)) prime?")
            }
            .disabled(isNthPrimeDisabled)
        }
        .font(.title)
        .navigationTitle("Counter Demo")
        .sheet(isPresented: $isPrimeSheetShown) {
            // onDismiss
        } content: {
            IsPrimeSheetView(store: store )
        }
        .alert("nth Prime", isPresented: $nthPrimeAlertShown) {
            Text("Ok")
        } message: {
            // the Text below gets build even before the alert is shown
            // can't have nthPrime! otherwise... crashes...
            Text("The \(ordinal(store.value.count)) prime is \(nthPrime ?? 0)")
        }

    }
}

//struct CounterView_Previews: PreviewProvider {
//    static var previews: some View {
//        CounterView(
//            store:
//                Store(
//                    initialValue: AppState(),
//                    reducer: appReducer
//                )
//        )
//    }
//}
