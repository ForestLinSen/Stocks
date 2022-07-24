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
        static let apiKey = ""
        static let sandboxApiKey = ""
        static let baseUrl = ""
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private enum APIError: Error{
        case invalidUrl
        case noDataReturned
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
