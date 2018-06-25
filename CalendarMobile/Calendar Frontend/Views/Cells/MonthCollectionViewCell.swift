//
//  MonthCollectionViewCell.swift
//  Calendar Frontend
//
//  Created by Gavi Rawson on 6/18/18.
//  Copyright © 2018 Graws Inc. All rights reserved.
//

import UIKit

protocol MonthCollectionViewCellDelegate {
    func didSelect(date: Date)
}

class MonthCollectionViewCell: UICollectionViewCell {
    
    // MARK:  Var
    // ********************************************************************************************
    
    var date: Date?                                     // Can be any day in the month
    var delegate: MonthCollectionViewCellDelegate?
    var eventsMapping: EventsMapping?
    
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
            let endPrev = Calendar.current.date(byAdding: DateComponents(month: -1, day: 0), to: startCurr)?.endOfMonth()
            else { return }
        
        // Weekday numbers
        let firstWeekdayCurr = Calendar.current.dateComponents([.weekday], from: startCurr).weekday!
        let lastWeekdayCurr = Calendar.current.dateComponents([.weekday], from: endCurr).weekday!
        let endPrevComponents = Calendar.current.dateComponents([.day, .year, .month], from: endPrev)
        
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
            if let mapping = eventsMapping, let date = date {
                var eventOnDays = Array(repeating: false, count: 7)
                for i in 0..<7 {
                    var currDateComp = Calendar.current.dateComponents([.year, .month], from: date)
                    currDateComp.day = days[i]
                    
                    if r == 0 && !currentMonth[i] { // prev month
                        currDateComp.month! -= 1
                    } else if r == weeksStack.arrangedSubviews.count-1 && !currentMonth[i] {    // next month
                        currDateComp.month! += 1
                    }
                    eventOnDays[i] = mapping.countEventsFor(Calendar.current.date(from: currDateComp)!) > 0
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
        
        var dateComp = Calendar.current.dateComponents([.year, .month, .day], from: self.date!)
        dateComp.day! = weekView.days![index]
        if weekView.tag == 0 && !(weekView.currentMonth?[index] ?? true) {  // prev month
            dateComp.month! -= 1
        } else if weekView.tag == weeksStack.arrangedSubviews.count-1 && !(weekView.currentMonth?[index] ?? true) {    // next month
            dateComp.month! += 1
        }
        delegate?.didSelect(date: Calendar.current.date(from: dateComp)!)
    }
}
