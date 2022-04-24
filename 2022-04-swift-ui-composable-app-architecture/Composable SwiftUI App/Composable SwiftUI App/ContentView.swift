//
//  ContentView.swift
//  Composable SwiftUI App
//
//  Created by Nicholas Tian on 14/4/2022.
//

import SwiftUI

struct WolframAlphaResult: Decodable {
    let queryresult: QueryResult
    
    struct QueryResult: Decodable {
        let pods: [Pod]
        
        struct Pod: Decodable {
            let primary: Bool?
            let subpods: [SubPod]
            
            struct SubPod: Decodable {
                let plaintext: String
            }
        }
    }
}

func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) {
    wolframAlpha(query: "prime \(n)") { result in
        callback(
            result
                .flatMap {
                    $0.queryresult
                        .pods
                        .first { $0.primary == true }?
                        .subpods
                        .first?
                        .plaintext
                }
                .flatMap(Int.init)
        )
    }
}

func wolframAlpha(
    query: String,
    callback: @escaping (WolframAlphaResult?) -> Void
) {
    var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
    
    components.queryItems = [
        URLQueryItem(name: "input", value: query),
        URLQueryItem(name: "format", value: "plaintext"),
        URLQueryItem(name: "output", value: "JSON"),
        URLQueryItem(name: "appid", value: Keychain.wolframAlphaAPIKey)
    ]
    
    let task = URLSession.shared.dataTask(with: components.url(relativeTo: nil)!) { data, response, error in
        let result = data.flatMap {
            try? JSONDecoder().decode(WolframAlphaResult.self, from: $0)
        }
        
        callback(result)
    }
    
    task.resume()
}

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
    @State var nthPrimeAlertShown: Bool = false
    @State var nthPrime: Int?

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
                Composable_SwiftUI_App.nthPrime(state.count) { optionalPrime in
                    guard let prime = optionalPrime else {
                        return
                    }
                    
                    print(prime)
                    
                    nthPrime = prime
                    nthPrimeAlertShown = true
                }
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
        .alert("nth Prime", isPresented: $nthPrimeAlertShown) {
            Text("Ok")
        } message: {
            // the Text below gets build even before the alert is shown
            // can't have nthPrime! otherwise... crashes...
            Text("The \(ordinal(state.count)) prime is \(nthPrime ?? 0)")
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(state: AppState())
    }
}
