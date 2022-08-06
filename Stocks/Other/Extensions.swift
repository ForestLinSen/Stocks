//
//  Extensions.swift
//  Stocks
//
//  Created by Sen Lin on 6/8/2022.
//

import Foundation
import UIKit

extension DateFormatter{
    static let newsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
}
