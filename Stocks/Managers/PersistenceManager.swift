//
//  PersistenceManager.swift
//  Stocks
//
//  Created by Sen Lin on 24/7/2022.
//

import Foundation


/// Object to manage saved caches
final class PersistenceManager{
    
    /// Singleton
    static let shared = PersistenceManager()
    
    /// Reference to user defaults
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
    
    
    /// Check if watch list contains item
    /// - Parameter symbol: Symbol to check
    /// - Returns: Boolean
    public func watchlistContains(symbol: String) -> Bool {
        return watchlist.contains(symbol)
    }
    
    /// Add a symbol to watchlist
    /// - Parameters:
    ///   - symbol: Symbol to add
    ///   - companyName: Company name for symbol being added
    public func addToWatchlist(symbol: String, companyName: String){
        var current = watchlist
        current.append(symbol)
        
        userDefaults.set(current, forKey: Constants.watchList)
        userDefaults.set(companyName, forKey: symbol)
        
        NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
    }
    
    /// Remove item from watchlist
    /// - Parameter symbol: Symbol to remove
    public func removeFromWatchlist(symbol: String){
        var newList = [String]()
        for item in watchlist where item != symbol {
            newList.append(item)
        }
        
        userDefaults.set(newList, forKey: Constants.watchList)
    }
    
    // MARK: - Private
    
    /// Cehck if user has been onboarded
    private var hasOnboarded: Bool {
        return userDefaults.bool(forKey: Constants.onboardedKey)
    }
    
    
    /// Set up default watclist items
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
