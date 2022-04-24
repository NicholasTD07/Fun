//
//  AppState.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import Foundation

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
