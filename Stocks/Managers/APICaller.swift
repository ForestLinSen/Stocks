//
//  APICaller.swift
//  Stocks
//
//  Created by Sen Lin on 24/7/2022.
//

import Foundation

/// Object to manage API calls
final class APICaller{
    /// Singleton
    public static let shared = APICaller()
    
    private struct Constants{
        static let apiKey = APIKeys.apiKey
        static let sandboxApiKey = APIKeys.sandBoxKey
        static let baseUrl = "https://finnhub.io/api/v1/"
    }
    
    // MARK: - Public
    
    
    /// Search for a company
    /// - Parameters:
    ///   - query: Query string (symbol or name)
    ///   - completion: Callback for the result: SearchResponse
    public func search(query: String, completion: @escaping (Result<SearchResponse, Error>) -> Void){
        // "https://finnhub.io/api/v1/search?q=someQuery"
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard safeQuery.count > 0, let url = createUrl(for: .search, queryParams: ["q":safeQuery]) else { return }
        
        request(url: url, expecting: SearchResponse.self, completion: completion)
    }
    
    
    /// Get news for type
    /// - Parameters:
    ///   - type: Company news or top news
    ///   - completion: Callback for the result: [NewsStory]
    public func fetchNews(
        for type: NewsViewController.NewsType,
        completion: @escaping (Result<[NewsStory], Error>) -> Void
    ){
        
        switch type {
        case .topStories:
            let url = createUrl(for: .topStories, queryParams: ["category": "general"])
            request(url: url, expecting: [NewsStory].self) { result in
                switch result {
                case .success(let stories):
                    completion(.success(stories))
                case .failure(let error):
                    print("Debug: cannot get top stories: \(error)")
                }
            }
        case .company(let symbol):
            let today = Date()
            let oneMonthBack = today.addingTimeInterval(-(3600 * 24 * 7)) // 3600 = 1 hour
            
            let url = createUrl(for: .company,
                                queryParams: [
                                    "symbol": symbol,
                                    "from": DateFormatter.newsDateFormatter.string(from: oneMonthBack),
                                    "to": DateFormatter.newsDateFormatter.string(from: today)
                                ])
            request(url: url, expecting: [NewsStory].self, completion: completion)
        }
    }
    
    
    /// Get market data
    /// - Parameters:
    ///   - symbol: Market symbol
    ///   - numberOfDays: Number of days back from today
    ///   - completion: Result Callback: MarketDataResponse
    public func marketData(
        for symbol: String,
        numberOfDays: Int = 7,
        completion: @escaping (Result<MarketDataResponse, Error>) -> Void
    ){
        let today = Date()
        let from = today.addingTimeInterval(-(3600 * 24 * Double(numberOfDays))) // 3600 = 1 hour
        
        let url = createUrl(for: .marketData, queryParams: [
            "symbol": symbol,
            "resolution": "1",
            "from": "\(Int(from.timeIntervalSince1970))",
            "to": "\(Int(today.timeIntervalSince1970))"
        ])
        
        request(url: url,
                expecting: MarketDataResponse.self,
                completion: completion)
        
    }
    
    
    /// Get financial metrics, like 52WeekHigh, beta, etc.
    /// - Parameters:
    ///   - symbol: Symbol of company
    ///   - completion: Result callback: Metrics Response
    public func searchMetrics(symbol: String, completion: @escaping (Result<MetricsResponse, Error>) -> Void) {
        let url = createUrl(for: .metrics, queryParams: [
            "symbol": symbol
        ])
        
        request(url: url, expecting: MetricsResponse.self, completion: completion)
    }
    
    // MARK: - Private
    private enum APIError: Error{
        case invalidUrl
        case noDataReturned
    }
    
    /// API endpoints. ex. https://finnhub.io/api/v1/news
    private enum Endpoint: String{
        case search
        case topStories = "news"
        case company = "company-news"
        case marketData = "stock/candle"
        case metrics = "stock/metric"
    }
    
    
    /// Create URL for endpoint
    /// - Parameters:
    ///   - endpoint: Endpoint to create for
    ///   - queryParams: Additional query arguments
    /// - Returns: Optional URL
    private func createUrl(for endpoint: Endpoint, queryParams: [String: String] = [:]) -> URL?{
        var urlString = Constants.baseUrl + endpoint.rawValue
        var queryItems = [URLQueryItem]()
        
        // add parameters
        for (key, value) in queryParams{
            queryItems.append(.init(name: key, value: value))
        }
        
        // add token
        queryItems.append(.init(name: "token", value: Constants.apiKey))
        
        // Convert query items to suffix string
        let queryString = queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        urlString += "?" + queryString
        
        print("Debug: url \(urlString)")
        return URL(string: urlString)
    }
    
    
    /// Perform API calls
    /// - Parameters:
    ///   - url: URL to hit
    ///   - expecting: Type we expect to decode data to
    ///   - completion: Result callback
    private func request<T: Codable>(url: URL?, expecting: T.Type, completion: @escaping (Result<T, Error>) -> Void){
        guard let url = url else{
            completion(.failure(APIError.invalidUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            
            guard let data = data, error == nil else{
                completion(.failure(error!))
                return
            }
            
            do{
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(.success(result))
            }catch{
                completion(.failure(error))
            }
        }
        
        task.resume()
        
    }
}
