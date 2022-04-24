//
//  ContentView.swift
//  Composable SwiftUI App
//
//  Created by Nicholas Tian on 14/4/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var state = AppState()
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: CounterView(state: state)
                ) {
                    Text("Counter Demo")
                }

                NavigationLink(
                    destination: FavoritePrimesView(state: state)
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
        ContentView(state: AppState())
    }
}
