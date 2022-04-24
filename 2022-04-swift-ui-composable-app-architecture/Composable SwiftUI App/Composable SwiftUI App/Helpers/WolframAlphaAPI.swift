//
//  WolframAlphaAPI.swift
//  Composable SwiftUI App
//
//  Created by Nicholas The Personal on 24/4/2022.
//

import Foundation

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
