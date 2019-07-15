//
//  APODResultCache.swift
//  APOD
//
//  Created by viwii on 2019/7/15.
//  Copyright © 2019 viwii. All rights reserved.
//

import Foundation
import CoreData

struct APODResultCache {
    
    private func fetch<E>(_ entity: E.Type, predicate: NSPredicate) -> E? where E: NSManagedObject {
        let request = NSFetchRequest<E>(entityName: "\(E.self)")
        request.predicate = predicate
        request.fetchLimit = 1
        
        do {
            return try request.execute().first
        } catch {
            print(#function, error.localizedDescription)
            return nil
        }
    }
    
    func read(of date: String) -> APODResult? {
        let context = DataController.default.context
        var result: APODEntity? = nil
        context.performAndWait {
            result = self.fetch(
                APODEntity.self,
                predicate: NSPredicate(format: "date==%@", date)
            )
        }
        guard
            let object = result,
            let title = object.title,
            let url = object.url,
            let dateStr = object.date,
            let explanation = object.explanation,
            let mt = object.mediaType
            else {
                print("APODResultCache missed APODResult")
                return nil
        }
        print("APODResultCache fetched APODResult")

        return APODResult(
            title: title,
            url: url,
            hdurl: object.hdurl,
            date: dateStr,
            explanation: explanation,
            media_type: mt,
            service_version: object.serviceVersion,
            copyright: object.copyright
        )
    }
    
    /// Insert new cache or update existed cache
    ///
    func write(result: APODResult) {
        let context = DataController.default.context

        context.perform {
            var e = self.fetch(
                APODEntity.self,
                predicate: NSPredicate(format: "date==%@", result.date)
            )
            if e == nil {
                e = APODEntity.init(context: context)
            }
            
            guard let object = e else {
                return
            }
            
            object.title = result.title
            object.url = result.url
            object.hdurl = result.hdurl
            object.date = result.date
            object.explanation = result.explanation
            object.mediaType = result.media_type
            object.serviceVersion = result.service_version
            object.copyright = result.copyright
            
            do {
                try context.save()
                print(#function, "APODResult cached!")
            } catch {
                print(#function, error.localizedDescription)
            }
        }
    }
    
    func read(imageURL: String) -> Data? {
        let context = DataController.default.context
        var result: ImageEntity? = nil
        context.performAndWait {
            result = fetch(
                ImageEntity.self,
                predicate: NSPredicate(format: "url==%@", imageURL)
            )
        }
        if let data = result?.data {
            print("APODResultCache fetched image data")
            return data
        }
        
        print("APODResultCache missed image data")
        return nil
    }
    
    /// Insert new cache or update existed cache
    ///
    func write(imageURL: String, data: Data) {
        let context = DataController.default.context
        
        context.perform {
            var e = self.fetch(
                ImageEntity.self,
                predicate: NSPredicate(format: "url==%@", imageURL)
            )
            if e == nil {
                e = ImageEntity(context: context)
            }
            
            guard let object = e else {
                return
            }
            
            object.url = imageURL
            object.data = data
            
            do {
                try context.save()
                print(#function, "Image cached!")
            } catch {
                print(#function, error.localizedDescription)
            }
        }
    }
}
