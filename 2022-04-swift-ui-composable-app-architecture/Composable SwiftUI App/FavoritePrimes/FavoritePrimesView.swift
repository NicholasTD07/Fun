//
//  FavoritePrimesView.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import SwiftUI

import ComposableArchitecture

public struct FavoritePrimesView: View {
    @ObservedObject var store: Store<[Int], FavoritePrimesAction>
    
    public var body: some View {
        List {
            ForEach(store.value, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in
                store.send(
                    action: .deleteFavoritePrimes(indexSet)
                )
            }
        }
        .navigationTitle("FavoritePrimes")
    }
    
    public init(store: Store<[Int], FavoritePrimesAction>) {
        self.store = store
    }
}

//struct FavoritePrimesView_Previews: PreviewProvider {
//    static var previews: some View {
//        FavoritePrimesView(
//            store:
//                Store(
//                    initialValue: Store(initialValue: [7, 11], reducer: { _, _ in}),
//                    reducer: appReducer
//                )
//        )
//    }
//}
