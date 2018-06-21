//
//  EventTableViewCell.swift
//  Calendar Frontend
//
//  Created by Gavi Rawson on 6/20/18.
//  Copyright © 2018 Graws Inc. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    // MARK:  Var
    // ********************************************************************************************
    
    var title: String?      { didSet { titleLabel.set(title: title, forStyle: LabelStyle.header ) } }
    var end: String?        { didSet { endLabel.set(title: end, forStyle: LabelStyle.subtitle) } }
    var start: String?      { didSet { startLabel.set(title: start, forStyle: LabelStyle.subtitle) } }
    
    fileprivate var titleLabel: UILabel = { return UILabel() }()
    fileprivate var startLabel: UILabel = { return UILabel() }()
    fileprivate var endLabel: UILabel = { return UILabel() }()
    
    fileprivate var separator: UILabel = {
       let x = UILabel()
        x.text = "•"
        x.textColor = Colors.separator
        return x
    }()
    
    fileprivate var c = [NSLayoutConstraint]()
    
    // MARK:  Init
    // ********************************************************************************************
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
        updateLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:  Func
    // ********************************************************************************************
    
    fileprivate func initViews() {
        backgroundColor = UIColor.clear
        
        addSubview(titleLabel)
        addSubview(startLabel)
        addSubview(endLabel)
        addSubview(separator)
    }
    
    fileprivate func updateLayout() {
        removeConstraints(c)
        c = []
        
        let views = [
            titleLabel, startLabel, endLabel,   // 0-2
            separator   // 3-5
        ]
        
        let metrics = [ Layout.margin]
        let formats = [
            "H:|-(m0)-[v1]-[v3]-[v2]",
            "H:|-(m0)-[v0]-(m0)-|",
            "V:|-(m0)-[v0]-[v1]-(m0)-|",
            "V:[v2]-(m0)-|"
        ]
        
        c = createConstraints(withFormats: formats, metrics: metrics, views: views)
        
        c += [
            endLabel.trailingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: trailingAnchor, multiplier: -Layout.margin),
            separator.centerYAnchor.constraint(equalTo: startLabel.centerYAnchor)
        ]
        addConstraints(c)
    }

}
