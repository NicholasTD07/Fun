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

private func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    
    formatter.numberStyle = .ordinal
    
    return formatter.string(for: n)!
}

struct CounterView: View {
    @State var count: Int = 0

    var body: some View {
        VStack {
            HStack {
                Button(action: { count -= 1 }) {
                        Text("-")
                }
                Text("\(count)")
                Button(action: { count += 1 }) {
                        Text("+")
                }
            }
            Button(action: {}) {
                    Text("Is this prime?")
            }
            Button(action: {
                
            }) {
                Text("What is the \(ordinal(count)) prime?")
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
