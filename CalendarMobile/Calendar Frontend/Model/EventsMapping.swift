//
//  EventsMapping.swift
//  Calendar Frontend
//
//  Created by Gavi Rawson on 6/24/18.
//  Copyright © 2018 Graws Inc. All rights reserved.
//

import Foundation

class EventsMapping {
    
    // MARK:  Var
    // ********************************************************************************************
    
    fileprivate struct Const {
        static let mappingFmt = "yyyy-MM-dd"
    }
    
    public var eventsMapping = [String: Int]()           // Maps date string to index of events in events array
    public var events = [[Event]]()                      // rows correspond to a single date
    fileprivate let formatter = DateFormatter()
    
    
    // MARK:  Public
    // ********************************************************************************************
    
    // Add an event to the event mapping
    public func add(_ event: Event) {
        let key = keyFor(event.startDate)
        
        if eventsMapping[key] == nil {
            events.append([Event]())
            eventsMapping[key] = events.count-1
        }
        events[eventsMapping[key]!].append(event)
    }
    
    // remove an event from the mapping based on the row and column values for the events array
    public func remove(_ event: Event) {
        let key = keyFor(event.startDate)
        guard let dateIndex = eventsMapping[key] else { return }
        
        // remove event for date
        for i in 0..<events[dateIndex].count {
            if events[dateIndex][i].id == event.id {
                events[dateIndex].remove(at: i)
                break
            }
        }
        
        // remove dict mapping to event
        if events[dateIndex].count == 0 {
            eventsMapping[key] = nil
        }
    }
    
    // Sort the events on a given date
    public func sortEventsFor(_ date: Date?) {
        guard let date = date else { return }
        let key = keyFor(date)
        guard let dateIndex = eventsMapping[key] else { return }
        events[dateIndex].sort { $0.startDate < $1.startDate }
    }
    
    // Returns the number of events on a specified date
    public func countEventsFor(_ date: Date?) -> Int {
        guard let date = date else { return 0 }
        let key = keyFor(date)
        guard let dateIndex = eventsMapping[key] else { return 0 }
        return events[dateIndex].count
    }
    
    // Get an event for a given date and index
    public func eventFor(_ date: Date?, atRow r: Int) -> Event? {
        guard let date = date else { return nil }
        let key = keyFor(date)
        guard let dateIndex = eventsMapping[key] else { return nil }
        return events[dateIndex][r]
    }
    
    // Load events between two dates inclusive
    public func loadEvents(start: Date, end: Date, completion: ((_ success: Bool) -> Void)?) {
        EventsManager.shared.getEvents(start: start, end: end) { [weak self] (events) in
            events?.forEach { self?.add($0) }
            
            if let completion = completion {
                completion(events != nil)
            }
        }
    }
    
    public func clear() {
        eventsMapping = [String: Int]()
        events = []
    }
    
    
    // MARK:  func
    // ********************************************************************************************
    
    // get the key in the events array for a given date
    fileprivate func keyFor(_ date: Date) -> String {
        formatter.dateFormat = Const.mappingFmt
        return formatter.string(from: date)
    }
    
    
}
