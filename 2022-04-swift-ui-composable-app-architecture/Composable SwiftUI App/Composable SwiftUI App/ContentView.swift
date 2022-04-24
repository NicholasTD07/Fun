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

import Combine

/*
 
   https://developer.apple.com/documentation/combine/observableobject
   https://developer.apple.com/forums/thread/127243
   https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-observedobject-to-manage-state-from-external-objects
   https://www.hackingwithswift.com/quick-start/swiftui/what-is-the-published-property-wrapper
   https://developer.apple.com/documentation/combine/published

 */

// in the tutorial
// class AppState: BindableObject {
class AppState: ObservableObject {
    @Published var count: Int = 0
    
    // in the tutorial
    // var didChange = PassthroughSubject<Void, Never>()
    
    // or like this
    // ref: https://www.avanderlee.com/swiftui/stateobject-observedobject-differences/
    func incrementCounter() {
        count += 1
        objectWillChange.send()
    }
}

struct CounterView: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack {
            HStack {
                Button(action: { state.count -= 1 }) {
                        Text("-")
                }
                Text("\(state.count)")
                Button(action: { state.count += 1 }) {
                        Text("+")
                }
            }
            Button(action: {}) {
                    Text("Is this prime?")
            }
            Button(action: {
                
            }) {
                Text("What is the \(ordinal(state.count)) prime?")
            }
        }
        .font(.title)
        .navigationTitle("Counter Demo")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(state: AppState())
    }
}
