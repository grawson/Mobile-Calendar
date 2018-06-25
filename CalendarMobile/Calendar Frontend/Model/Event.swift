//
//  Event.swift
//  Calendar Frontend
//
//  Created by Gavi Rawson on 6/19/18.
//  Copyright © 2018 Graws Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class Event: NSCopying {
    
    fileprivate struct Const {
        static let readFmt = "yyyy-MM-dd HH:mm:ss"
    }
    
    fileprivate var formatter = DateFormatter()
    
    var id: Int = -1
    var title: String?
    var startDate: Date!
    var endDate: Date!
     
    // MARK:  Init
    // ********************************************************************************************
    
    init(title: String, start: Date, end: Date) {
        self.title = title
        self.startDate = start
        self.endDate = end
    }

    init(json: JSON) {
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = Const.readFmt

        title = json["title"].string
        id = json["id"].int ?? -1
        
        if let startDate = json["start_date"].string {
            self.startDate = formatter.date(from: startDate)
        }
        
        if let endDate = json["end_date"].string {
            self.endDate = formatter.date(from: endDate)
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Event(title: title ?? "", start: startDate, end: endDate)
        copy.id = id
        return copy
    }

}
