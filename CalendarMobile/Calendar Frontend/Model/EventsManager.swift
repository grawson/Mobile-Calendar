//
//  EventsManager.swift
//  Calendar Frontend
//
//  Created by Gavi Rawson on 6/19/18.
//  Copyright © 2018 Graws Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class EventsManager {
    
    // MARK:  Var
    // ********************************************************************************************
    
    static var shared = EventsManager()

    fileprivate var formatter: DateFormatter = {
        let x = DateFormatter()
        x.dateFormat = "yyyy-MM-dd HH:mm:ss"
        x.timeZone = TimeZone(abbreviation: "UTC")
        return x
    }()
    
    // MARK:  Func
    // ********************************************************************************************
    
    // Load all events
    public func getAllEvents(completion: @escaping (_ events: [Event]) -> Void ) {
        getAllEvents(params: nil, completion: completion)
    }
    
    // Load all events between given dates
    public func getEvents(start: Date, end: Date, completion: @escaping (_ events: [Event]) -> Void ) {
        let params: Parameters = [
            "start_date": formatter.string(from: start),
            "end_date": formatter.string(from: end)
        ]
        getAllEvents(params: params, completion: completion)
    }
    
    // Save an event and update its ID based on the response
    public func saveEvent(_ event: Event, completion: @escaping (_ success: Bool) -> Void) {
        let parameters: Parameters = [
            "title": event.title ?? "",
            "start_date": formatter.string(from: event.startDate),
            "end_date": formatter.string(from: event.endDate)
        ]
        
        let url = "http://\(Config.domain)/events"
        Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
            if let json = response.result.value {
                let swiftyJSON = JSON(json)
                let success = swiftyJSON["code"].int ?? -1 == 200
                
                event.id = Int(swiftyJSON["data"].stringValue) ?? -1  // Update id for event
                completion(success)
            }
        }
    }
    
    public func updateEvent(_ event: Event, completion: @escaping (_ success: Bool) -> Void) {
        let parameters: Parameters = [
            "title": event.title ?? "",
            "start_date": formatter.string(from: event.startDate),
            "end_date": formatter.string(from: event.endDate),
            "id": event.id
        ]
        
        let url = "http://\(Config.domain)/events"
        Alamofire.request(url, method: .put, parameters: parameters).responseJSON { response in     
            if let json = response.result.value {
                let swiftyJSON = JSON(json)
                let success = swiftyJSON["code"].int ?? -1 == 200
                completion(success)
            }
        }
    }
    
    public func deleteEvent(_ event: Event, completion: @escaping (_ success: Bool) -> Void) {
        let parameters: Parameters = [
            "id": event.id
        ]
        
        let url = "http://\(Config.domain)/events"
        Alamofire.request(url, method: .delete, parameters: parameters).responseJSON { response in
            if let json = response.result.value {
                let swiftyJSON = JSON(json)
                let success = swiftyJSON["code"].int ?? -1 == 200
                completion(success)
            }
        }
    }
    
    // Generic events loader
    fileprivate func getAllEvents(params: Parameters?, completion: @escaping (_ events: [Event]) -> Void ) {
        
        Alamofire.request("http://\(Config.domain)/events", parameters: params).responseJSON { response in
            var events = [Event]()
            if let json = response.result.value {
                let swiftyJSON = JSON(json)
                
                for eventJSON in swiftyJSON.arrayValue {
                    let event = Event(json: eventJSON)
                    events.append(event)
                }
            }
            completion(events)
        }
    }
}
