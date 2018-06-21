//
//  MonthCollectionViewCell.swift
//  Calendar Frontend
//
//  Created by Gavi Rawson on 6/18/18.
//  Copyright © 2018 Graws Inc. All rights reserved.
//

import UIKit

protocol MonthCollectionViewCellDelegate {
    
    
    /// Called when a day has been selected.
    ///
    /// - Parameters:
    ///   - day: The day number
    ///   - month: 0 if in currently displayed month, -1 if previous, 1 if next
    func didSelectDay(day: Int, month: Int)
}

class MonthCollectionViewCell: UICollectionViewCell {
    
    // MARK:  Var
    // ********************************************************************************************
    
    var date: Date?                                     // Can be any day in the month
    var delegate: MonthCollectionViewCellDelegate?
    var eventsMapping: [String: Int]?                   // Maps date string to index of events in events array
    
    fileprivate var c = [NSLayoutConstraint]()
    fileprivate var weekContainingToday: WeekView?      // week containing selected day
    
    fileprivate var weeksStack: UIStackView = {
        let x = UIStackView()
        x.axis = .vertical
        x.distribution = .equalCentering
        
        // add 5 weeks
        for i in 0...4 {
            let v = WeekView()
            v.days = Array(repeating: 0, count: 7)
            v.tag = i
            x.addArrangedSubview(v)
        }
        return x
    }()
    
    
    // MARK: Init
    // ********************************************************************************************
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Colors.blue1
        initViews()
        updateLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:  Func
    // ********************************************************************************************
    
    fileprivate func initViews() {
        for view in weeksStack.arrangedSubviews {
            (view as! WeekView).delegate = self
        }
        
        contentView.addSubview(weeksStack)
    }
    
    fileprivate func updateLayout() {
        removeConstraints(c)
        c = []
        
        let views = [ weeksStack ]
        let metrics = [ Layout.margin ]
        let formats = [
            "H:|-(m0)-[v0]-(m0)-|",
            "V:|[v0]|"
        ]
        
        c = createConstraints(withFormats: formats, metrics: metrics, views: views)
        addConstraints(c)
    }
    
    // Update the month view
    public func update() {

        // calculate start/end points for current month
        guard
            let startCurr = date?.startOfMonth(),
            let endCurr = date?.endOfMonth(),
            let endPrev = Calendar.current.date(byAdding: DateComponents(month: -1, day: 0), to: startCurr)?.endOfMonth(),
            let next = Calendar.current.date(byAdding: DateComponents(month: 1, day: 0), to: startCurr)
            else { return }
        
        // Weekday numbers
        let firstWeekdayCurr = Calendar.current.dateComponents([.weekday], from: startCurr).weekday!
        let lastWeekdayCurr = Calendar.current.dateComponents([.weekday], from: endCurr).weekday!
        let endPrevComponents = Calendar.current.dateComponents([.day, .year, .month], from: endPrev)
        let nextComponents = Calendar.current.dateComponents([.year, .month], from: next)
        let currComponents = Calendar.current.dateComponents([.year, .month], from: endCurr)
        
        var currDay = 1
        for r in 0..<weeksStack.arrangedSubviews.count {
            let weekView = weeksStack.arrangedSubviews[r] as! WeekView
            var days = Array(repeating: 0, count: 7)            // Day number for the weekday
            var currentMonth = Array(repeating: true, count: 7) // Day is in the current month
            
            // populate weekday numbers
            for c in 0..<7 {
                switch r {
                case 0:    // first week
                    if c < firstWeekdayCurr-1 {     // prev month
                        let offset = 6 - (firstWeekdayCurr-2)
                        days[c] = endPrevComponents.day! - (6-offset-c)
                        currentMonth[c] = false
                    } else {
                        days[c] = currDay
                        currDay += 1
                    }
                case weeksStack.arrangedSubviews.count-1:   // last week
                    if c > lastWeekdayCurr-1 {  // next month
                        days[c] = c - (lastWeekdayCurr-1)
                        currentMonth[c] = false
                    } else {
                        days[c] = currDay
                        currDay += 1
                    }
                default:
                    days[c] = currDay
                    currDay += 1
                }
            }
            
            // Update week view with results
            weekView.days = days
            weekView.currentMonth = currentMonth
            
            // Update event markers on each day
            if let mapping = eventsMapping {
                var eventOnDays = Array(repeating: false, count: 7)
                for i in 0..<7 {
                    var key = ""
                    if r == 0 && !currentMonth[i] { // prev month
                        key = String(format: "%d-%02d-%02d", endPrevComponents.year!, endPrevComponents.month!, days[i])
                    } else if r == weeksStack.arrangedSubviews.count-1 && !currentMonth[i] {    // next month
                        key = String(format: "%d-%02d-%02d", nextComponents.year!, nextComponents.month!, days[i])
                    } else {    // this month
                        key = String(format: "%d-%02d-%02d", currComponents.year!, currComponents.month!, days[i])
                    }
                    eventOnDays[i] = mapping[key] != nil
                }
                weekView.eventOnDay = eventOnDays
            }
        }
    }
    
    public func clearToday() {
        weekContainingToday?.today = nil
    }
    
}

// MARK:  Week view delegate
// ********************************************************************************************


extension MonthCollectionViewCell: WeekViewDelegate {
    func didSelectDay(_ weekView: WeekView, index: Int) {
        
        // reset today
        weekContainingToday?.today = nil
        weekContainingToday = weekView
        weekView.today = index
        
        var month = 0
        if weekView.tag == 0 && !(weekView.currentMonth?[index] ?? true) {  // prev month
            month = -1
        } else if weekView.tag == weeksStack.arrangedSubviews.count-1 && !(weekView.currentMonth?[index] ?? true) {    // next month
            month = 1
        }
        delegate?.didSelectDay(day: weekView.days?[index] ?? -1, month: month)
    }
}
