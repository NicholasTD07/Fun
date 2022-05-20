//
//  FavoritePrimesView.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import SwiftUI
import ComposableArchitecture

struct FavoritePrimesView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        List {
            ForEach(store.value.savedPrimes, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in
                store.send(
                    action: .favoritePrimes(
                        .deleteFavoritePrimes(indexSet)
                    )
                )
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
                    reducer: appReducer
                )
        )
    }
}
