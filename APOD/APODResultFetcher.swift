//
//  APODResultFetcher.swift
//  APOD
//
//  Created by viwii on 2019/7/15.
//  Copyright © 2019 viwii. All rights reserved.
//

import Foundation
import RxSwift


/// Parameter   Type    Default     Description
/// date    YYYY-MM-DD    today    The date of the APOD image to retrieve
/// hd      bool    False    Retrieve the URL for the high resolution image
/// api_key string    DEMO_KEY    api.nasa.gov key for expanded usage
///
public let APODURL = "https://api.nasa.gov/planetary/apod"
public let APODMethod = "GET"
public let APODAPIDemoKey = "DEMO_KEY"


final public class APODResultFetcher {
    
    private let disposeBag = DisposeBag()
    
    private let cacher = APODResultCache()

    private func requestURL(URLPath: String, query: [String:String]) -> URL? {
        guard
            let url = URL(string: URLPath),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            else {
                return nil
        }
        components.queryItems = query.compactMap { URLQueryItem(name: $0, value: $1) }
        return components.url
    }
    
    public func request(URLPath: String, query: [String:String]) -> Observable<APODResult> {
        guard let url = requestURL(URLPath: URLPath, query: query) else {
            return Observable.just(APODResult.empty).share(replay: 1, scope: .forever)
        }
        let request = URLRequest(url: url)
        let observable = URLSession.shared
            .rx
            .response(request: request)
            .map { try JSONDecoder().decode(APODResult.self, from: $1) }
            .catchErrorJustReturn(.empty)
            .share(replay: 1, scope: .forever)

        observable
            .filter { !$0.date.isEmpty && !$0.url.isEmpty }
            .subscribe(onNext: { [weak self] (result) in
                self?.cacher.write(result: result)
            })
            .disposed(by: disposeBag)
        
        return observable
    }
    
    public func request(date: Date) -> Observable<APODResult> {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let dateString = format.string(from: date)
        
        // look for cache
        if let exist = cacher.read(of: dateString) {
            return Observable.of(exist).share(replay: 1, scope: .forever)
        }
        
        // send request
        return request(
            URLPath: APODURL,
            query: [
                "date":dateString,
                "hd":"TRUE",
                "api_key":APODAPIDemoKey
            ]
        )
    }
    
    public func downloadImage(URLPath: String) -> Observable<Data> {
        // read cache
        if let exist = cacher.read(imageURL: URLPath) {
            return Observable.of(exist).share(replay: 1, scope: .forever)
        }
        
        // send request
        guard let url = URL(string: URLPath) else {
            return Observable.of(Data()).share(replay: 1, scope: .forever)
        }
        let observable = URLSession.shared
            .rx
            .data(request: URLRequest(url: url))
            .retry(1)
            .catchErrorJustReturn(Data())
            .share(replay: 1, scope: .forever)
        
        observable
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] (data) in
                self?.cacher.write(imageURL: URLPath, data: data)
            })
            .disposed(by: disposeBag)
        
        return observable
    }
}
