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
    @Published var savedPrimes: [Int] = []
    // in the tutorial
    // var didChange = PassthroughSubject<Void, Never>()
    
    // or like this
    // ref: https://www.avanderlee.com/swiftui/stateobject-observedobject-differences/
    func incrementCounter() {
        count += 1
        objectWillChange.send()
    }
}

func isPrime(_ n: Int) -> Bool {
    if n <= 1 {
        return false
    }
    if n <= 3 {
        return true
    }
    
    for i in 2...(Int(sqrtf(Float(n)))) {
        if n % i == 0 {
            return false
        }
    }
    
    return true
}

struct IsPrimeSheetView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        
        if isPrime(state.count) {
            Text("\(state.count) is prime! 🎉")
            
            if state.savedPrimes.contains(state.count) {
                Button {
                    state.savedPrimes.removeAll {
                        $0 == state.count
                    }
                } label: {
                    Text("Remove from favorite primes...")
                }
            } else {
                Button {
                    state.savedPrimes.append(state.count)
                } label: {
                    Text("Save to favorite primes!")
                }
            }

        } else {
            Text("\(state.count) is not prime! 🙁")
        }
    }
}

struct CounterView: View {
    @ObservedObject var state: AppState
    @State var isPrimeSheetShown: Bool = false

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

            } label: {
                Text("What is the \(ordinal(state.count)) prime?")
            }
        }
        .font(.title)
        .navigationTitle("Counter Demo")
        .sheet(isPresented: $isPrimeSheetShown) {
            // onDismiss
        } content: {
            IsPrimeSheetView(state: state)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(state: AppState())
    }
}
