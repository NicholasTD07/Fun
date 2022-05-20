//
//  CounterView.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import SwiftUI

import ComposableArchitecture

import PrimeModal

public struct CounterViewState {
    public var count: Int
    public var savedPrimes: [Int]
    
    public init(count: Int, savedPrimes: [Int]) {
        self.count = count
        self.savedPrimes = savedPrimes
    }

    var primeModal: PrimeModalState {
        get {
            (count: count, savedPrimes: savedPrimes)
        }
        set {
            count = newValue.count
            savedPrimes = newValue.savedPrimes
        }
    }
}

public enum CounterViewAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
    
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

private let box = ReducerTypeBox<CounterViewState, CounterViewAction>.self

private let viewCounterReducer = box.pullback(reducer: counterReducer(value:action:), writableValueKeyPath: \.count, readableActionKeyPath: \.counterAction)
private let viewPrimeModalReducer = box.pullback(reducer: primeModalReducer(value:action:), writableValueKeyPath: \.primeModal, readableActionKeyPath: \.primeModalAction)

public let counterViewReducer = box.combine(
    reducers: [
        viewCounterReducer,
        viewPrimeModalReducer,
    ]
)

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(
            store:
                Store(
                    initialValue: .init(count: 1_000_000, savedPrimes: [7, 11]),
                    reducer: counterViewReducer
                )
        )
    }
}
