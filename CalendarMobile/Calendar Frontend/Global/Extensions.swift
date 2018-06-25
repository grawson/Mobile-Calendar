//
//  Extensions.swift
//  Calendar Frontend
//
//  Created by Gavi Rawson on 6/18/18.
//  Copyright © 2018 Graws Inc. All rights reserved.
//

import UIKit

extension UIView {
    
    // create constraints with visual format language
    func createConstraints(withFormats: [String], metrics: [CGFloat]?, views: [UIView]) -> [NSLayoutConstraint] {
        
        var viewsDict = [String: UIView]()
        for (i, val) in views.enumerated() {
            viewsDict["v\(i)"] = val
        }
        
        var metricsDict = [String: CGFloat]()
        if let metrics = metrics {
            for (i, val) in metrics.enumerated()  {
                metricsDict["m\(i)"] = val
            }
        }
        
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        var constraints = [NSLayoutConstraint]()
        withFormats.forEach {
            constraints += NSLayoutConstraint.constraints(withVisualFormat: $0, options: NSLayoutFormatOptions(), metrics: metricsDict, views: viewsDict)
        }
        return constraints
    }
}

extension UILabel {
    
    // set a label text with specified attributes
    func set(title: String?, forStyle attr: [NSAttributedStringKey: Any]) {
        guard let title = title else { return }
        attributedText = NSAttributedString(string: title, attributes: attr)
    }
}

extension Date {
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}

extension Comparable {
    
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension UIButton {
    
    func set(title: String, states: [UIControlState], forStyle attr: [NSAttributedStringKey: Any]) {
        for state in states {
            let attributedTitle = NSAttributedString(string: title, attributes: attr)
            setAttributedTitle(attributedTitle, for: state)
        }
    }
}


