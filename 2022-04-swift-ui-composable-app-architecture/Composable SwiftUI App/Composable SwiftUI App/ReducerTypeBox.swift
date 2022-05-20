//
//  ReducerTypeBox.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 20/5/2022.
//

import Foundation

enum ReducerTypeBox<Value, Action> {
    typealias Reducer = (inout Value, Action) -> Void
    typealias HigherOrderReducer = (@escaping Reducer) -> Reducer
    
    static func wrapping(
        reducer: @escaping Reducer,
        with higherOrderReducers: [HigherOrderReducer]
    ) -> Reducer {
        let wrapped = higherOrderReducers.reduce(reducer) { (reducer, higherOrderReducer) -> Reducer in
            higherOrderReducer(reducer)
        }
        
        return wrapped
    }

    static func combine(
      reducers: [(inout Value, Action) -> Void]
    ) -> (inout Value, Action) -> Void {
        { value, action in
            reducers.forEach { reducer in
                reducer(&value, action)
            }
        }
    }
    
    static func pullback<LocalValue, LocalAction>(
        reducer: @escaping (inout LocalValue, LocalAction) -> Void,
        writableValueKeyPath: WritableKeyPath<Value, LocalValue>,
        readableActionKeyPath: KeyPath<Action, LocalAction?>
    ) -> (inout Value, Action) -> Void {
        { (globalValue, globalAction) in
            guard
                let localAction = globalAction[keyPath: readableActionKeyPath]
            else {
                return
            }
            
            reducer(&globalValue[keyPath: writableValueKeyPath], localAction)
        }
    }
}
