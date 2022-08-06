//
//  NewsStory.swift
//  Stocks
//
//  Created by Sen Lin on 6/8/2022.
//

import Foundation

struct NewsStory: Codable{
    let category: String
    let datetime: TimeInterval
    let headline: String
    let id: Int
    let image: String
    let source: String
    let summary: String
    let url: String
}

