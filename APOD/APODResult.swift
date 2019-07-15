//
//  APODResult.swift
//  APOD
//
//  Created by viwii on 2019/7/14.
//  Copyright © 2019 viwii. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import RxCocoa

public struct APODResult: Codable {
    
    public var title: String
    public var url: String
    public var hdurl: String?
    public var date: String
    public var explanation: String
    
    /// like: image
    public var media_type: String
    public var service_version: String?
    public var copyright: String?

    
    public var isImage: Bool { media_type == "image" }
    public var bestChoice: String { hdurl ?? url }
}

//public extension APODResult {
//    
//    static func requestURL(URLPath: String, query: [String:String]) -> URL? {
//        guard
//            let url = URL(string: URLPath),
//            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
//            else {
//                return nil
//        }
//        components.queryItems = query.compactMap { URLQueryItem(name: $0, value: $1) }
//        return components.url
//    }
//    
//    static func request(URLPath: String, query: [String:String]) -> Observable<APODResult> {
//        do {
//            guard let url = requestURL(URLPath: URLPath, query: query) else {
//                throw URLError(.badURL)
//            }
//            let request = URLRequest(url: url)
//            let observable = URLSession.shared
//                .rx
//                .response(request: request)
//                .map { try JSONDecoder().decode(APODResult.self, from: $1) }
//            
//            let disposeBag = DisposeBag()
//            observable.subscribe(onNext: { (result) in
//                APODResultCache.write(result: result)
//            }) {
//                print("APODResultCache.write result disposed!")
//            }.disposed(by: disposeBag)
//            
//            return observable
//        } catch {
//            return Observable.empty()
//        }
//    }
//    
//    static func request(date: Date) -> Observable<APODResult> {
//        let format = DateFormatter()
//        format.dateFormat = "yyyy-MM-dd"
//        let dateString = format.string(from: date)
//        
//        // look for cache
//        if let exist = APODResultCache.read(of: dateString) {
//            return Observable.of(exist)
//        }
//        
//        // send request
//        return request(
//            URLPath: APODURL,
//            query: [
//                "date":dateString,
//                "hd":"TRUE",
//                "api_key":APODAPIDemoKey
//            ]
//        )
//    }
//    
//    static func downloadImage(URLPath: String) -> Observable<Data> {
//        do {
//            // read cache
//            if let exist = APODResultCache.read(imageURL: URLPath) {
//                return Observable.of(exist)
//            }
//            
//            // send request
//            guard let url = URL(string: URLPath) else {
//                throw URLError(.badURL)
//            }
//            let observable = URLSession.shared
//                .rx
//                .data(request: URLRequest(url: url))
//            
//            let disposeBag = DisposeBag()
//            observable.subscribe(onNext: { (data) in
//                APODResultCache.write(imageURL: URLPath, data: data)
//            }) {
//                print("APODResultCache.write image data disposed!")
//            }.disposed(by: disposeBag)
//            
//            return observable
//        } catch {
//            return Observable.empty()
//        }
//    }
//}
