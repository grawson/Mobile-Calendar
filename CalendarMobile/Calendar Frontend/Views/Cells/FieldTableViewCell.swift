//
//  FieldTableViewCell.swift
//  Calendar Frontend
//
//  Created by Gavi Rawson on 6/20/18.
//  Copyright © 2018 Graws Inc. All rights reserved.
//

import UIKit

class FieldTableViewCell: UITableViewCell {
    
    // MARK:  Var
    // ********************************************************************************************

    // the current title in the field
    var title: String? {
        get {
            return field.text
        } set {
            field.text = newValue
        }
    }
    
    fileprivate var c = [NSLayoutConstraint]()
    
    fileprivate var field: UITextField = {
        let x = UITextField()
        x.attributedPlaceholder = NSAttributedString(string: "Title", attributes: LabelStyle.fadedRegular)
        x.textColor = LabelStyle.regular[.foregroundColor]! as? UIColor
        x.font = LabelStyle.regular[.font]! as? UIFont
        x.keyboardAppearance = .alert
        return x
    }()
    
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
        backgroundColor = Colors.blue3
        addSubview(field)
    }
    
    fileprivate func updateLayout() {
        removeConstraints(c)
        c = []
        
        let views = [ field ]
        let metrics = [ Layout.margin ]
        let formats = [
            "H:|-(m0)-[v0]-(m0)-|",
            "V:|-(m0)-[v0]-(m0)-|"
        ]
        
        c = createConstraints(withFormats: formats, metrics: metrics, views: views)
        addConstraints(c)
    }

}
