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
    var selectedDate: Date?                             // Date to circle in the calendar
    
    fileprivate var c = [NSLayoutConstraint]()
    fileprivate var weekContainingSelectedDay: WeekView?      // week containing selected day
    
    fileprivate var weeksStack: UIStackView = {
        let x = UIStackView()
        x.axis = .vertical
        x.distribution = .equalCentering
        
        // add necessary number of weeks
        for i in 0...5 {
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
        let formats = [
            "H:|-[v0]-|",
            "V:|-[v0]-|"
        ]
        
        c = createConstraints(withFormats: formats, metrics: nil, views: views)
        addConstraints(c)
    }
    
    public func update() {
        guard let date = date else { return }
        
        // calculate starting point in previous month
        let startOfMonth = date.startOfMonth()
        let startOfMonthComp = Calendar.current.dateComponents([.weekday, .month], from: startOfMonth)
        let daysOffset = startOfMonthComp.weekday! - 1
        var currDate = Calendar.current.date(byAdding: DateComponents(month: 0, day: -daysOffset), to: startOfMonth)!
        
        for r in 0..<weeksStack.arrangedSubviews.count {
            let weekView = weeksStack.arrangedSubviews[r] as! WeekView
            var days = Array(repeating: 0, count: 7)
            var currentMonth = Array(repeating: false, count: 7)
            
            for c in 0..<7 {
                currDate = Calendar.current.date(byAdding: DateComponents(day: 1), to: currDate)!
                let currComp = Calendar.current.dateComponents([.day, .month], from: currDate)
                days[c] = currComp.day!
                currentMonth[c] = currComp.month! == startOfMonthComp.month!
            }
            weekView.days = days
            weekView.currentMonth = currentMonth
        }
    }
    
    // Update the month view. Redraws day labels, draws event overlays if needed, highlights today, and highlights selected day
//    public func update() {
//        guard let date = date else { return }
//
//        // reset month
//        weekContainingSelectedDay = nil
//        for r in 0..<weeksStack.arrangedSubviews.count {
//            let weekView = weeksStack.arrangedSubviews[r] as! WeekView
//            weekView.todayIndex = nil
//            weekView.selectedIndex = nil
//        }
//
//        let startCurr = date.startOfMonth()
//        let endCurr = date.endOfMonth()
//        guard let endPrev = Calendar.current.date(byAdding: DateComponents(month: -1, day: 0), to: startCurr)?.endOfMonth() else { return }
//        let firstWeekdayCurr = Calendar.current.dateComponents([.weekday], from: startCurr).weekday!
//        let lastWeekdayCurr = Calendar.current.dateComponents([.weekday], from: endCurr).weekday!
//        let endPrevComponents = Calendar.current.dateComponents([.day, .year, .month], from: endPrev)
//
//        // variables to check if today is in this month
//        let currComp = Calendar.current.dateComponents([.year, .month], from: date)
//        let todayComp = Calendar.current.dateComponents([.year, .month, .day], from: Date())
//        let todayDay = todayComp.year! == currComp.year! && todayComp.month! == currComp.month! ? todayComp.day! : nil
//
//        var currDay = 1
//        for r in 0..<weeksStack.arrangedSubviews.count {
//            let weekView = weeksStack.arrangedSubviews[r] as! WeekView
//            var days = Array(repeating: 0, count: 7)            // Day number for the weekday
//            var currentMonth = Array(repeating: true, count: 7) // Day is in the current month
//
//            // populate weekday numbers
//            for c in 0..<7 {
//                switch r {
//                case 0:    // first week
//                    if c < firstWeekdayCurr-1 {     // prev month
//                        let offset = 6 - (firstWeekdayCurr-2)
//                        days[c] = endPrevComponents.day! - (6-offset-c)
//                        currentMonth[c] = false
//                    } else {
//                        days[c] = currDay
//                        currDay += 1
//                    }
//                case weeksStack.arrangedSubviews.count-1:   // last week
//                    if c > lastWeekdayCurr-1 {  // next month
//                        days[c] = c - (lastWeekdayCurr-1)
//                        currentMonth[c] = false
//                    } else {
//                        days[c] = currDay
//                        currDay += 1
//                    }
//                default:
//                    days[c] = currDay
//                    currDay += 1
//                }
//            }
//
//            // Update week view with results
//            weekView.days = days
//            weekView.currentMonth = currentMonth
//
//            // get components for selecte date
//            var selectedComp: DateComponents?
//            if let selectedDate = selectedDate {
//                selectedComp = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
//            }
//
//            // Update event markers on each day
//            if let mapping = eventsMapping {
//                var eventOnDays = Array(repeating: false, count: 7)
//                for i in 0..<7 {
//
//                    // check for and highlight today
//                    if let todayDay = todayDay, todayDay == weekView.days![i] {
//                        weekView.todayIndex = i
//                    }
//
//                    // Get the date components for the date
//                    var currDateComp = Calendar.current.dateComponents([.year, .month], from: date)
//                    currDateComp.day = days[i]
//                    if r == 0 && !currentMonth[i] { // prev month
//                        currDateComp.month! -= 1
//                    } else if r == weeksStack.arrangedSubviews.count-1 && !currentMonth[i] {    // next month
//                        currDateComp.month! += 1
//                    }
//
//                    // update tvents overlay for day if needed
//                    eventOnDays[i] = mapping.countEventsFor(Calendar.current.date(from: currDateComp)!) > 0
//
//                    // check if should select the day
//                    if let selectedComp = selectedComp, selectedComp == currDateComp {
//                        weekView.selectedIndex = i
//                        weekContainingSelectedDay = weekView
//                    }
//                }
//                weekView.eventOnDay = eventOnDays
//            }
//        }
//    }
    
    public func clearSelectedDay() {
        weekContainingSelectedDay?.selectedIndex = nil
        selectedDate = nil
    }
}

// MARK:  Week view delegate
// ********************************************************************************************


extension MonthCollectionViewCell: WeekViewDelegate {
    func didSelectDay(_ weekView: WeekView, index: Int) {
        guard !(weekView.tag == weekContainingSelectedDay?.tag && weekContainingSelectedDay?.selectedIndex == index) else { return }    // guards against tapping same button again
        
        // reset selected day
        weekContainingSelectedDay?.selectedIndex = nil
        weekContainingSelectedDay = weekView
        weekContainingSelectedDay?.selectedIndex = index
        
        // calculate date for selected day
        var dateComp = Calendar.current.dateComponents([.year, .month, .day], from: self.date!)
        dateComp.day! = weekView.days![index]
        if weekView.tag == 0 && !(weekView.currentMonth?[index] ?? true) {  // prev month
            dateComp.month! -= 1
        } else if weekView.tag == weeksStack.arrangedSubviews.count-1 && !(weekView.currentMonth?[index] ?? true) {    // next month
            dateComp.month! += 1
        }
        
        selectedDate = Calendar.current.date(from: dateComp)!
        delegate?.didSelect(date: selectedDate!)
    }
}
