//
//  Style.swift
//  Calendar Frontend
//
//  Created by Gavi Rawson on 6/18/18.
//  Copyright © 2018 Graws Inc. All rights reserved.
//

import UIKit

struct Layout {
    static let margin: CGFloat = 16
}

struct Colors {
    static let tint = UIColor(red: 248/255, green: 140/255, blue: 140/255, alpha: 1)
    
    static let titleText = UIColor(red: 234/255, green: 241/255, blue: 248/255, alpha: 1)
    static let subtitleText = UIColor(red: 146/255, green: 163/255, blue: 183/255, alpha: 1)
    static let faded = UIColor(red: 70/255, green: 79/255, blue: 89/255, alpha: 1)
    static let buttonText = UIColor(red: 161/255, green: 180/255, blue: 204/255, alpha: 1)
    
    static let separator = UIColor(red: 1, green: 1, blue: 1, alpha: 0.10)
    
    static let blue1 = UIColor(red: 21/255, green: 28/255, blue: 36/255, alpha: 1)
    static let blue2 = UIColor(red: 29/255, green: 39/255, blue: 47/255, alpha: 1)
    static let blue3 = UIColor(red: 29/255, green: 36/255, blue: 44/255, alpha: 1)
    static let blue4 = UIColor(red: 36/255, green: 45/255, blue: 56/255, alpha: 1)
    static let translucentNav = UIColor(red: 9/255, green: 19/255, blue: 27/255, alpha: 1)
}


struct LabelStyle {
    
    static let strongTitle: [NSAttributedString.Key: Any] = [
        .foregroundColor: Colors.titleText,
        .font: UIFont.systemFont(ofSize: 28, weight: .heavy)]
    
    static let lightTitle: [NSAttributedString.Key: Any] = [
        .foregroundColor: Colors.titleText,
        .font: UIFont.systemFont(ofSize: 28, weight: .light)]
    
    static let regular: [NSAttributedString.Key: Any] = [
        .foregroundColor: Colors.titleText,
        .font: UIFont.systemFont(ofSize: 15, weight: .regular)]
    
    static let header: [NSAttributedString.Key: Any] = [
        .foregroundColor: Colors.titleText,
        .font: UIFont.systemFont(ofSize: 15, weight: .semibold)]
    
    static let subtitle: [NSAttributedString.Key: Any] = [
        .foregroundColor: Colors.subtitleText,
        .font: UIFont.systemFont(ofSize: 15, weight: .regular)]
    
    static let darkRegular: [NSAttributedString.Key: Any] = [
        .foregroundColor: Colors.blue1,
        .font: UIFont.systemFont(ofSize: 15, weight: .regular)]
    
    static let fadedRegular: [NSAttributedString.Key: Any] = [
        .foregroundColor: Colors.faded,
        .font: UIFont.systemFont(ofSize: 15, weight: .regular)]
    
    static let fadedHeader: [NSAttributedString.Key: Any] = [
        .foregroundColor: Colors.faded,
        .font: UIFont.systemFont(ofSize: 20, weight: .regular)]
    
    static let button: [NSAttributedString.Key: Any] = [
        .foregroundColor: Colors.tint,
        .font: UIFont.systemFont(ofSize: 15, weight: .regular)]
    
    static let largeButton: [NSAttributedString.Key: Any] = [
        .foregroundColor: Colors.tint,
        .font: UIFont.systemFont(ofSize: 17, weight: .regular)]
}
