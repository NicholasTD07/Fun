//
//  ContentView.swift
//  Composable SwiftUI App
//
//  Created by Nicholas Tian on 14/4/2022.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    @StateObject var store = Store(
        initialValue: AppState(),
        reducer: appReducer
    )
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: CounterView(store: store)
                ) {
                    Text("Counter Demo")
                }

                NavigationLink(
                    destination: FavoritePrimesView(store: store)
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
