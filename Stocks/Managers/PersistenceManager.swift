//
//  PersistenceManager.swift
//  Stocks
//
//  Created by Sen Lin on 24/7/2022.
//

import Foundation

final class PersistenceManager{
    static let shared = PersistenceManager()
    
    private let userDefaults: UserDefaults = .standard
    
    private struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchList = "watchlist"
    }
    
    private init() {}
    
    // MARK: - Public
    public var watchlist: [String] {
        if !hasOnboarded{
            userDefaults.setValue(true, forKey: Constants.onboardedKey)
            setUpDefaults()
        }
        
        return userDefaults.stringArray(forKey: Constants.watchList) ?? []
    }
    
    public func watchlistContains(symbol: String) -> Bool {
        return watchlist.contains(symbol)
    }
    
    public func addToWatchlist(symbol: String, companyName: String){
        var current = watchlist
        current.append(symbol)
        
        userDefaults.set(current, forKey: Constants.watchList)
        userDefaults.set(companyName, forKey: symbol)
        
        NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
    }
    
    public func removeFromWatchlist(symbol: String){
        var newList = [String]()
        for item in watchlist where item != symbol {
            newList.append(item)
        }
        
        userDefaults.set(newList, forKey: Constants.watchList)
    }
    
    // MARK: - Private
    private var hasOnboarded: Bool {
        return userDefaults.bool(forKey: Constants.onboardedKey)
    }
    
    private func setUpDefaults() {
        let map: [String: String] = [
            "AAPL": "Apple Inc",
            "MSFT": "Microsoft Corporation",
            "GOOG": "Alphabet"
        ]
        
        let symbols = map.keys.map{ $0 }
        userDefaults.setValue(symbols, forKey: "watchlist")
        
        for (symbol, name) in map{
            userDefaults.set(name, forKey: symbol)
        }
    }
}
