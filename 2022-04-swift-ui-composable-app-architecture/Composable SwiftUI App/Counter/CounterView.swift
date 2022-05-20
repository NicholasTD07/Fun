//
//  CounterView.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import SwiftUI

import ComposableArchitecture

import PrimeModal

public typealias CounterViewState = (count: Int, savedPrimes: [Int])

public enum CounterViewAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
}

public struct CounterView: View {
    @ObservedObject var store: Store<CounterViewState, CounterViewAction>

    @State var nthPrime: Int?

    @State var isPrimeSheetShown = false
    @State var nthPrimeAlertShown = false
    @State var isNthPrimeDisabled = false

    public var body: some View {
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
                Counter.nthPrime(store.value.count) { optionalPrime in
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
            IsPrimeSheetView(
                store: store.transform {
                    ($0.count, $0.savedPrimes)
                } action: { action in
                    .primeModal(action)
                }
            )
        }
        .alert("nth Prime", isPresented: $nthPrimeAlertShown) {
            Text("Ok")
        } message: {
            // the Text below gets build even before the alert is shown
            // can't have nthPrime! otherwise... crashes...
            Text("The \(ordinal(store.value.count)) prime is \(nthPrime ?? 0)")
        }

    }
    
    public init(store: Store<CounterViewState, CounterViewAction>) {
        self.store = store
    }
}

private func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    
    formatter.numberStyle = .ordinal
    
    return formatter.string(for: n)!
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
