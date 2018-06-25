//
//  WeekView.swift
//  Calendar Frontend
//
//  Created by Gavi Rawson on 6/18/18.
//  Copyright © 2018 Graws Inc. All rights reserved.
//

import UIKit

protocol WeekViewDelegate {
    func didSelectDay(_ weekView: WeekView, index: Int)
}

class WeekView: UIView {

    // MARK:  Var
    // ********************************************************************************************

    fileprivate struct Const {
        static let todayOverlayHeight: CGFloat = 40
        static let eventMarkerHeight: CGFloat = 5
        static let buttonSize: CGFloat = 40
    }
    
    var delegate: WeekViewDelegate?
    var today: Int?             { didSet { updateToday(oldValue: oldValue) } }      // Index of today in the days stack
    var currentMonth: [Bool]?   { didSet { updateDays() } }                         // Flags indicating the day is in the current month
    var days: [Int]?            { didSet { updateDays() } }                         // Day numbers for the week
    var eventOnDay: [Bool]?     { didSet { updateEventOnDays() } }                  // Marker if there is an event in a day
    var todayIndex: Int?        { didSet { updateDays() } }                         // index of today in the days array
    
    fileprivate var c = [NSLayoutConstraint]()
    fileprivate var eventMarkers = [UIView]()
    
    fileprivate var daysStack: UIStackView = {
        let x = UIStackView()
        x.axis = .horizontal
        x.distribution = .equalCentering
        x.spacing = 4
        
        // add day labels
        for i in 0...6 {
            let button = UIButton()
            button.tag = i
            button.addTarget(self, action: #selector(dayTapped(_:)), for: .touchUpInside)
            x.addArrangedSubview(button)
        }
        
        return x
    }()
    
    fileprivate var todayOverlay: UIView = {
        let x = UIView()
        x.backgroundColor = Colors.titleText
        
        // shadow
        x.layer.masksToBounds = false
        x.layer.shadowColor = Colors.titleText.cgColor
        x.layer.shadowOpacity = 0.4
        x.layer.shadowOffset = .zero
        x.layer.shadowRadius = 6
        return x
    }()
    
    // MARK: Init
    // ********************************************************************************************
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        updateLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:  Life Cycle
    // ********************************************************************************************
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if todayOverlay.superview != nil {
            todayOverlay.layer.cornerRadius = todayOverlay.frame.height / 2
        }
        
        for marker in eventMarkers {
            marker.layer.cornerRadius = marker.frame.height / 2
        }
    }
    
    
    // MARK:  Func
    // ********************************************************************************************
    
    fileprivate func initViews() {
        addSubview(daysStack)
    }
    
    fileprivate func updateLayout() {
        removeConstraints(c)
        c = []
        
        let views = [ daysStack ]
        let formats = [
            "H:|[v0]|",
            "V:|[v0]|"
        ]
        
        c = createConstraints(withFormats: formats, metrics: nil, views: views)
        
        for view in daysStack.arrangedSubviews {
            c += [
                view.heightAnchor.constraint(equalToConstant: Const.buttonSize),
                view.widthAnchor.constraint(equalToConstant: Const.buttonSize)
            ]
        }
        
        addConstraints(c)
    }
    
    // Redraw day numbers and their colors
    fileprivate func updateDays() {
        guard
            let days = days,
            let currentMonth = currentMonth,
            days.count == currentMonth.count,
            days.count == daysStack.arrangedSubviews.count
            else { return }
        
        for i in 0...daysStack.arrangedSubviews.count-1 {
            let button = daysStack.arrangedSubviews[i] as! UIButton
            
            var attr = LabelStyle.regular
            if todayIndex == i {
                attr = LabelStyle.button
            } else if !currentMonth[i] {
                attr = LabelStyle.fadedRegular
            }
            
            button.set(title: "\(days[i])", states: [.normal, .highlighted], forStyle: attr)
            button.set(title: "\(days[i])", states: [.selected], forStyle: LabelStyle.darkRegular)
            if (today == i) { button.isSelected = true }
        }
    }
    
    fileprivate func updateToday(oldValue: Int?) {
        // Clear today overlay
        if todayOverlay.superview != nil {
            todayOverlay.removeFromSuperview()
            
            if let oldValue = oldValue {
                let oldButton = daysStack.arrangedSubviews[oldValue] as! UIButton
                oldButton.isSelected = false
            }
        }
        
        guard let today = today else { return }
        
        // insert above event markers
        insertSubview(todayOverlay, at: eventMarkers.count)
        
        // Constraints
        let anchor = daysStack.arrangedSubviews[today]
        todayOverlay.translatesAutoresizingMaskIntoConstraints = false
        todayOverlay.centerXAnchor.constraint(equalTo: anchor.centerXAnchor).isActive = true
        todayOverlay.centerYAnchor.constraint(equalTo: anchor.centerYAnchor).isActive = true
        todayOverlay.heightAnchor.constraint(equalToConstant: Const.todayOverlayHeight).isActive = true
        todayOverlay.widthAnchor.constraint(equalToConstant: Const.todayOverlayHeight).isActive = true
        setNeedsLayout()
        layoutIfNeeded()
        
        // Animate today overlay in
        todayOverlay.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: .curveEaseIn, animations: { [weak self] in
            self?.todayOverlay.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)

        // Update todays color
        UIView.animate(withDuration: 0.17, animations: {
        }) { [weak self] (completed) in
            guard completed else { return }
            (self?.daysStack.arrangedSubviews[today] as! UIButton).isSelected = true
        }
    }
    
    fileprivate func updateEventOnDays() {
        guard
            let eventOnDay = eventOnDay,
            eventOnDay.count == daysStack.arrangedSubviews.count
        else { return }
        
        // Clear current markers
        for marker in eventMarkers {
            marker.removeFromSuperview()
        }
        eventMarkers = []
        
        // Add event markers
        for i in 0..<eventOnDay.count {
            if eventOnDay[i] {
                let marker = UIView()
                marker.backgroundColor = Colors.tint
                eventMarkers.append(marker)
                insertSubview(marker, at: 0)
                
                // Constraints
                let anchor = daysStack.arrangedSubviews[i] as! UIButton
                marker.translatesAutoresizingMaskIntoConstraints = false
                marker.centerXAnchor.constraint(equalTo: anchor.centerXAnchor).isActive = true
                marker.topAnchor.constraint(equalTo: anchor.lastBaselineAnchor, constant: 8).isActive = true
                marker.heightAnchor.constraint(equalToConstant: Const.eventMarkerHeight).isActive = true
                marker.widthAnchor.constraint(equalToConstant: Const.eventMarkerHeight).isActive = true
            }
        }
    }
    
    // MARK:  Event listeners
    // ********************************************************************************************
    
    @objc func dayTapped(_ sender: UIButton) {
        delegate?.didSelectDay(self, index: sender.tag)
    }
    
}
