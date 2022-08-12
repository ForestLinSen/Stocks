//
//  MarketDataResponse.swift
//  Stocks
//
//  Created by Sen Lin on 12/8/2022.
//

import Foundation

struct MarketDataResponse: Codable{
    let open: [Double]
    let close: [Double]
    let high: [Double]
    let low: [Double]
    let status: String
    let timestamps: [TimeInterval]
    
    enum CodingKeys: String, CodingKey{
        case open = "o"
        case low = "l"
        case close = "c"
        case high = "h"
        case status = "s"
        case timestamps = "t"
    }
}
