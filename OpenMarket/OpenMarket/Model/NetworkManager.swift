//
//  NetworkManager.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/07/12.
//

import Foundation

class NetworkManager {
    let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func fetch<T: Decodable>(for url: String, dataType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let url = URL(string: url) else {
            return
        }
        
        let dataTask: URLSessionDataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let response = response as? HTTPURLResponse else {
                return
            }
            
            if (200..<400).contains(response.statusCode) {
                do {
                    let data = try JSONDecoder().decode(dataType, from: data)
                    completion(.success(data))
                } catch {
                    completion(.failure(NetworkError.failToDecoding))
                }
            } else {
                completion(.failure(NetworkError.outOfRange))
            }
        })
        dataTask.resume()
    }
}
