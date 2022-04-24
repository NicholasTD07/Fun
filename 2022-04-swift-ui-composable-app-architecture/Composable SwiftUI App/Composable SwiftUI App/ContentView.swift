//
//  ContentView.swift
//  Composable SwiftUI App
//
//  Created by Nicholas Tian on 14/4/2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: CounterView()
                ) {
                    Text("Counter Demo")
                }

                NavigationLink(
                    destination: EmptyView()
                ) {
                    Text("Favorite Primes")
                }
            }
            // On the List
            .navigationBarTitle("State Management")
        }
    }
}

struct CounterView: View {
    var body: some View {
        VStack {
            HStack {
                Button(action: {}) {
                        Text("-")
                }
                Text("0")
                Button(action: {}) {
                        Text("+")
                }
            }
            Button(action: {}) {
                    Text("Is this prime?")
            }
            Button(action: {}) {
                    Text("What is the 0th prime?")
            }
        }
        .font(.title)
        .navigationTitle("Counter Demo")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
