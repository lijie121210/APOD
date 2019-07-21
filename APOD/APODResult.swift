//
//  APODResult.swift
//  APOD
//
//  Created by viwii on 2019/7/14.
//  Copyright © 2019 viwii. All rights reserved.
//

import Foundation

public struct APODResult: Codable {
    
    public var title: String
    public var url: String
    public var hdurl: String?
    public var date: String
    public var explanation: String
    
    /// like: image, video
    public var media_type: String
    public var service_version: String?
    public var copyright: String?

    
    public var isImage: Bool { media_type == "image" }
    public var bestChoice: String { hdurl ?? url }
}

extension APODResult {
    
    static var empty: APODResult {
        return APODResult(
            title: "No Data",
            url: "",
            hdurl: nil,
            date: "",
            explanation: "",
            media_type: "",
            service_version: nil,
            copyright: nil
        )
    }
}
