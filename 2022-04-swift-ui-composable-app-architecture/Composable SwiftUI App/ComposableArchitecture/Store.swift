//
//  Store.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 20/5/2022.
//

import Foundation
import Combine

/*
 
   https://developer.apple.com/documentation/combine/observableobject
   https://developer.apple.com/forums/thread/127243
   https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-observedobject-to-manage-state-from-external-objects
   https://www.hackingwithswift.com/quick-start/swiftui/what-is-the-published-property-wrapper
   https://developer.apple.com/documentation/combine/published

 */

public final class Store<Value, Action>: ObservableObject {
    @Published public private(set) var value: Value
    
    private let reducer: (inout Value, Action) -> Void

    private var cancellable: Cancellable?
    
    public init(initialValue: Value, reducer:  @escaping (inout Value, Action) -> Void) {
        self.value = initialValue
        self.reducer = reducer
    }
    
    public func send(action: Action) {
        reducer(&value, action)
    }
    
    public func transform<LocalValue, LocalAction>(
        value valueTransform: @escaping (Value) -> LocalValue,
        action actionTransform: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction> {
        // 1. Transform the current store to a `Store` with `LocalValue`
        let localStore = Store<LocalValue, LocalAction>(
            initialValue: valueTransform(value)
        ) { [weak self] inoutLocalValue, action in
            guard let self = self else {
                assertionFailure("A local store shouldn't reference the global store when it is gone...")
                return
            }
            
            // 2. Whatever Action happens on this local store is propagated back to the current store
            self.reducer(&self.value, actionTransform(action))
            
            // 3. The result of the action is also propagted onto the local store as well
            inoutLocalValue = valueTransform(self.value)
        }
        
        // 4. Whatever change happens to the value on the global store
        //    is also propagated to the local store
        localStore.cancellable = self.$value.sink { [weak localStore] value in
            localStore?.value = valueTransform(value)

            if let localStore = localStore {
                print(Unmanaged.passUnretained(localStore).toOpaque(), localStore.value)
            }
        }
        
        //    QUESTION: Isn't the local store's value getting updated twice? 🤔
        //              when an action happens to the local store?
        //    NOTE: From my testing, it doesn't seem like
        //          we need to update the localStore's value ourselves at all. It's getting updated.
        //          But I don't understand where it was getting updated...
        //    OH I SEE NOW! Because the AppStore's value got updated so
        //      ContentView's views got updated and then The FavoritePrimesView also gets an update.
        //      YARP. The address of the local store keeps changing. 🤷
        
        return localStore
    }
}
