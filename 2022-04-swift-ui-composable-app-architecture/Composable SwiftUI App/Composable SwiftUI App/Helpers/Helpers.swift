//
//  Helpers.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import Foundation

func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    
    formatter.numberStyle = .ordinal
    
    return formatter.string(for: n)!
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
