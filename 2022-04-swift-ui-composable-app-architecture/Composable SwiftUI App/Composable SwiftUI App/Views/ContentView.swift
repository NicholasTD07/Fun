//
//  ContentView.swift
//  Composable SwiftUI App
//
//  Created by Nicholas Tian on 14/4/2022.
//

import SwiftUI
import ComposableArchitecture

import Counter
import FavoritePrimes

struct ContentView: View {
    @StateObject var store = Store(
        initialValue: AppState(),
        reducer: appReducer
    )
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: CounterView(
                        store: store.transform {
                            (count: $0.count, savedPrimes: $0.savedPrimes)
                        } action: {
                            switch $0 {
                            case let .counter(action):
                                return .counter(action)
                            case let .primeModal(action):
                                return .primeModal(action)
                            }
                        }
                    )
                ) {
                    Text("Counter Demo")
                }

                NavigationLink(
                    destination: FavoritePrimesView(
                        store: store.transform {
                            $0.savedPrimes
                        } action: {
                            .favoritePrimes($0)
                        }
                    )
                ) {
                    Text("Favorite Primes")
                }
            }
            // On the List
            .navigationBarTitle("State Management")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store:
                Store(
                    initialValue: AppState(),
                    reducer: appReducer
                )
        )
    }
}
