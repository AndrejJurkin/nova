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
//  MenuBarViewModel.swift
//  Nova
//
//  Created by Andrej Jurkin on 9/3/17.

import Foundation
import RxSwift

class MenuBarViewModel {
    
    let repo = Injector.inject(type: DataRepository.self)
    
    let prefs = Injector.inject(type: Prefs.self)
    
    var menuBarText = Variable("N O V A")
    
    var pinnedSymbols: Variable<[String]> = Variable([])
    
    var isRefreshing = Variable<Bool>(false)
    
    var pinnedCurrencies = Variable<[String: Double]>([:])
    
    let disposeBag = DisposeBag()
    
    init() {
        
    }
    
    /// Subscribe for ticker updates
    ///
    /// - parameters:
    ///    - base: The base currency symbol (1 base unit is priced at x target units)
    ///    - refreshInterval: The ticker refresh interval in seconds
    func subscribeForTickerUpdates(base: String, refreshInterval: Float) {
        Observable<Int>.interval(RxTimeInterval(refreshInterval), scheduler: MainScheduler.instance)
            .flatMap { _ -> Observable<CryptonatorTickerResponse> in
                return Api.shared.getTicker(base: base, target: self.prefs.targetCurrency)
            }
            .subscribe(onNext: { response in
                guard response.success == true, let ticker = response.ticker else {
                    return
                }
                
                self.pinnedCurrencies.value[ticker.base] = ticker.price
            })
            .addDisposableTo(disposeBag)
    }

}
