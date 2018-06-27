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
    var eventsMapping: EventsMapping?                   // Used to check for events on a given date
    var selectedDate: Date?                             // Date to circle in the calendar
    
    fileprivate var c = [NSLayoutConstraint]()
    fileprivate var weekContainingSelectedDay: WeekView?      // week containing selected day (white circle)
    
    fileprivate var weeksStack: UIStackView = {
        let x = UIStackView()
        x.axis = .vertical
        x.distribution = .equalCentering
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
    
    // add necessary number of weeks for the given month (min is 4, max is 6)
    fileprivate func initWeeksStack() {
        guard let date = date else { return }
        weeksStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let weeks = Calendar.current.dateComponents([.weekOfMonth], from: date.endOfMonth()).weekOfMonth!
        
        for i in 0..<weeks {
            let v = WeekView()
            v.days = Array(repeating: 0, count: 7)
            v.delegate = self
            v.tag = i
            weeksStack.addArrangedSubview(v)
        }
    }
    
    // Update the month view. Redraws day labels, draws event overlays if needed, highlights today, and highlights selected day
    public func update() {
        guard let date = date, let eventsMapping = eventsMapping else { return }
        
        initWeeksStack()
        
        // calculate starting point in previous month, along with some other helper variables
        let startOfMonth = date.startOfMonth()
        let startOfMonthComp = Calendar.current.dateComponents([.weekday, .month], from: startOfMonth)
        let daysOffset = startOfMonthComp.weekday! - 1
        var currDate = Calendar.current.date(byAdding: DateComponents(month: 0, day: -daysOffset), to: startOfMonth)!
        let todayComp = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        let selectedComp = selectedDate != nil ? Calendar.current.dateComponents([.year, .month, .day], from: selectedDate!) : nil  // the day to select
    
        for r in 0..<weeksStack.arrangedSubviews.count {    // for each week
            let weekView = weeksStack.arrangedSubviews[r] as! WeekView
            var days = Array(repeating: 0, count: 7)
            var eventOnDays = Array(repeating: false, count: 7)
            var currentMonth = Array(repeating: false, count: 7)
            var dates = [Date]()
            
            for c in 0..<7 {    // for each day in the week
                let currComp = Calendar.current.dateComponents([.day, .month, .year], from: currDate)
                days[c] = currComp.day!
                currentMonth[c] = currComp.month! == startOfMonthComp.month!
                eventOnDays[c] = eventsMapping.countEventsFor(currDate) > 0
                dates.append(currDate)
                
                // check for today
                if currComp == todayComp {
                    weekView.todayIndex = c
                }
                
                // check if should select the day
                if let selectedComp = selectedComp, selectedComp == currComp {
                    weekView.selectedIndex = c
                    weekContainingSelectedDay = weekView
                }
                
                currDate = Calendar.current.date(byAdding: DateComponents(day: 1), to: currDate)!   // increment day
            }
            
            // update week values
            weekView.days = days
            weekView.currentMonth = currentMonth
            weekView.eventOnDay = eventOnDays
            weekView.dates = dates
        }
    }

    public func clearSelectedDay() {
        weekContainingSelectedDay?.selectedIndex = nil
        selectedDate = nil
    }
}

// MARK:  Week view delegate
// ********************************************************************************************


extension MonthCollectionViewCell: WeekViewDelegate {
    func didSelectDay(_ weekView: WeekView, date: Date, selectedIndex: Int) {
       
        // reset selected day
        weekContainingSelectedDay?.selectedIndex = nil
        weekContainingSelectedDay = weekView
        weekView.selectedIndex = selectedIndex
        
        delegate?.didSelect(date: date)
    }
}
