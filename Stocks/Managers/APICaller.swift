//
//  APICaller.swift
//  Stocks
//
//  Created by Sen Lin on 24/7/2022.
//

import Foundation

final class APICaller{
    
    static let shared = APICaller()
    
    private struct Constants{
        static let apiKey = APIKeys.apiKey
        static let sandboxApiKey = APIKeys.sandBoxKey
        static let baseUrl = "https://finnhub.io/api/v1/"
    }
    
    // MARK: - Public
    public func search(query: String, completion: @escaping (Result<SearchResponse, Error>) -> Void){
        // "https://finnhub.io/api/v1/search?q=someQuery"
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard safeQuery.count > 0, let url = createUrl(for: .search, queryParams: ["q":safeQuery]) else { return }
        
        request(url: url, expecting: SearchResponse.self, completion: completion)
    }
    
    // MARK: - Private
    private enum APIError: Error{
        case invalidUrl
        case noDataReturned
    }
    
    private enum Endpoint: String{
        case search
    }
    
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
