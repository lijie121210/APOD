//
//  APODResult.swift
//  APOD
//
//  Created by viwii on 2019/7/14.
//  Copyright © 2019 viwii. All rights reserved.
//

import Foundation
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

/// Parameter   Type    Default     Description
/// date    YYYY-MM-DD    today    The date of the APOD image to retrieve
/// hd      bool    False    Retrieve the URL for the high resolution image
/// api_key string    DEMO_KEY    api.nasa.gov key for expanded usage
///
public let APODURL = "https://api.nasa.gov/planetary/apod"
public let APODMethod = "GET"
public let APODAPIDemoKey = "DEMO_KEY"

public extension APODResult {
    
    static func requestURL(URLPath: String, query: [String:String]) -> URL? {
        guard
            let url = URL(string: URLPath),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            else {
                return nil
        }
        components.queryItems = query.compactMap { URLQueryItem(name: $0, value: $1) }
        return components.url
    }
    
    static func request(URLPath: String, query: [String:String]) -> Observable<APODResult> {
        do {
            guard let url = requestURL(URLPath: URLPath, query: query) else {
                throw URLError(.badURL)
            }
            let request = URLRequest(url: url)
            return URLSession.shared
                .rx
                .response(request: request)
                .map { try JSONDecoder().decode(APODResult.self, from: $1) }
        } catch {
            return Observable.empty()
        }
    }
    
    static func downloadImage(URLPath: String) -> Observable<Data> {
        do {
            guard let url = URL(string: URLPath) else {
                throw URLError(.badURL)
            }
            return URLSession.shared
                .rx
                .data(request: URLRequest(url: url))
        } catch {
            return Observable.empty()
        }
    }
}
