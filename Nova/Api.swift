//
//  CoinMarketCapDataSource.swift
//  Nova
//
//  Created by Andrej Jurkin on 9/3/17.
//  Copyright © 2017 Andrej Jurkin. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class Api {
    
    public static let shared: Api = Api()
    
    private var coinMarketCapProvider: RxMoyaProvider<CoinMarketCapProvider>
    private var cryptonatorProvider: RxMoyaProvider<CryptonatorProvider>
    private let providerPlugins = [NetworkLoggerPlugin()]
    
    init() {
        self.coinMarketCapProvider = RxMoyaProvider(plugins: providerPlugins)
        self.cryptonatorProvider = RxMoyaProvider(plugins: providerPlugins)
    }
    
    /// Get all crypto currency tickers
    func getAllTickers() -> Observable<[Ticker]> {
        
        return self.coinMarketCapProvider.request(.allTickers)
            .map(toArray: Ticker.self)
    }
    
    /// Get top N (limit) tickers, sorted by market cap
    func getTopTickers(limit: Int) -> Observable<[Ticker]> {
        
        return self.coinMarketCapProvider.request(.topTickers(limit: limit))
            .map(toArray: Ticker.self)
    }
    
    /// Get ticker for single crypto currency
    func getTicker(currencyName: String) -> Observable<Ticker> {
        
        return self.coinMarketCapProvider.request(.ticker(currencyName: currencyName))
            .map(to: Ticker.self)
    }
    
    /// Get ticker from Cryptonator api
    ///
    /// Endpoint updates every 30s
    ///
    /// - Parameters:
    ///    - base: The base currency symbol (1 base unit is priced at x target units)
    ///    - target: The target currency symbol
    func getTicker(base: String, target: String) -> Observable<CryptonatorTickerResponse> {
        
        return self.cryptonatorProvider.request(.ticker(base: base, target: target))
            .map(to: CryptonatorTickerResponse.self)
    }
}
