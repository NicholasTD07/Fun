//
//  FavoritePrimesView.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import SwiftUI

struct FavoritePrimesView: View {
    @ObservedObject var store: Store<AppState, CounterAction>
    
    var body: some View {
        List {
            ForEach(store.value.savedPrimes, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    // I don't think this is logically correct tho...
                    // if you are removing multiple indices at the same time...
                    store.value.savedPrimes.remove(at: index)
                    
                    // but so far the UI doesn't allow you to remove more than one item... okay...
                }
            }
        }
        .navigationTitle("FavoritePrimes")
    }
}

struct FavoritePrimesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritePrimesView(
            store:
                Store(
                    initialValue: AppState(),
                    reducer: counterReducer
                )
        )
    }
}
