//
//  Extensions.swift
//  Stocks
//
//  Created by Sen Lin on 6/8/2022.
//

import Foundation
import UIKit

extension String{
    static func string(from timeInterval: TimeInterval) -> String{
        let date = Date(timeIntervalSince1970: timeInterval)
        return DateFormatter.prettyDateFormatter.string(from: date)
    }
}

extension DateFormatter{
    static let newsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    
    static let prettyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}
