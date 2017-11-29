//
//  Copyright 2017 Andrej Jurkin.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//
//  LocalDataSource.swift
//  Nova
//
//  Created by Andrej Jurkin on 9/3/17.

import Foundation
import RealmSwift
import RxRealm
import RxSwift

class LocalDataSource {
    
    let defaultSortOrder = [
        SortDescriptor(keyPath: "isPinned", ascending: false),
        SortDescriptor(keyPath: "rank", ascending: true)
    ]
    
    var prefs: Prefs
    
    init(prefs: Prefs) {
        self.prefs = prefs
    }
    
    /// Asyncroniously cache tickers into Realm
    func saveTickersAsync(tickers: [Ticker]) {
        DispatchQueue(label: "realm").async {
            autoreleasepool {
                self.saveTickers(tickers: tickers)
            }
        }
    }
    
    /// Synchroniously cache tickers into Realm
    func saveTickers(tickers: [Ticker]) {
        let realm = try! Realm()
        try! realm.write {
            for ticker in tickers {
                // Generic fix for symbol collisions.
                // Some unknown altcoins may have colliding symbols with (BTC, ETH..), this is a problem,
                // because we use ticker symbol as a primary key for cryptocompare requests.
                // The trade-off is to drop altcoins with colliding symbols and only display the ticker with the highest market cap.
                if let localTicker = realm.object(ofType: Ticker.self, forPrimaryKey: ticker.symbol) {
                    // Skip all colliding ticker symbols
                    if localTicker.id != ticker.id && localTicker.rank < ticker.rank {
                        continue
                    }
                }
    
                realm.create(Ticker.self, value: ticker.toDictionary(), update: true)
            }
        }
    }
    
    /// Cache a single ticker into Realm
    func saveTicker(ticker: Ticker) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.create(Ticker.self, value: ticker.toDictionary(), update: true)
        }
    }
    
    func updateTickerPrices(tickers: [String: [String: Double]]) {
        let realm = try! Realm()
        
        try! realm.write {
            for (key, prices) in tickers {
                
                if let updatedPrice = prices[prefs.targetCurrency] {
                    realm.create(Ticker.self, value: ["symbol": key, "price": updatedPrice], update: true)
                }
            }
        }
    }
    
    func updateTickerPrice(symbol: String, newPrice: Double) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.create(Ticker.self, value: ["symbol": symbol, "priceUsd": newPrice], update: true)
        }
    }
    
    /// Return all tickers cached in Realm
    /// - Ordered by market cap, pinned tickers first
    func getAllTickers() -> Observable<[Ticker]> {
        let realm = try! Realm()
        
        let tickers = realm
            .objects(Ticker.self)
            .sorted(by: defaultSortOrder)
        
        return Observable.array(from: tickers)
    }
    
    /// Get pinned tickers sorted by orderIndex
    func getPinnedTickers() -> Observable<[Ticker]> {
        let realm = try! Realm()
        
        let pinnedTickers = realm
            .objects(Ticker.self)
            .filter("isPinned = true")
            .sorted(by: defaultSortOrder)

        return Observable.array(from: pinnedTickers)
    }
    
    func isTickerPinned(symbol: String) -> Bool {
        let realm = try! Realm()
        
        guard let ticker =
            realm.object(ofType: Ticker.self, forPrimaryKey: symbol) else {
                return false
        }
        
        return ticker.isPinned
    }
    
    /// Set ticker as pinned (show in menu bar)
    func pinTicker(symbol: String) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.create(Ticker.self, value: ["symbol": symbol, "isPinned": true], update: true)
        }
    }
    
    /// Unpin ticker (remove from menu bar)
    func unpinTicker(symbol: String) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.create(Ticker.self, value: ["symbol": symbol, "isPinned": false], update: true)
        }
    }
}
