//
//  SearchResponse.swift
//  Stocks
//
//  Created by Sen Lin on 30/7/2022.
//

import Foundation

struct SearchResponse: Codable{
    let count: Int
    let result: [SearchResult]
}

struct SearchResult: Codable{
    let description: String
    let displaySymbol: String
    let type: String
}

//{
//"count": 29,
//"result": [
//{
//"description": "ALPHABET INC-CL C",
//"displaySymbol": "GOOG",
//"symbol": "GOOG",
//"type": "Common Stock"
//},
//{
//"description": "ALPHABET INC-CL C",
//"displaySymbol": "GOOG.SN",
//"symbol": "GOOG.SN",
//"type": "Common Stock"
//},
//{
//"description": "LS 1X GOOG",
//"displaySymbol": "GOOG.AS",
//"symbol": "GOOG.AS",
//"type": "ETP"
