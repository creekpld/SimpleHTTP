//
//  HTTP.swift
//  A simple library to make HTTP Requests using URLRequest and Codable Data.
//
//  Created by Philipp Dylong on 27.02.19.
//  Copyright © 2019 Philipp Dylong. All rights reserved.
import Foundation

public func httpSync(_ url: String,
                     _ method: String = "GET",
                     _ body: Data? = nil,
                     _ allHTTPHeaderFields: [String : String]? = nil,
                    timeout: TimeInterval = 60)
    -> Data? {
    
    var responseData: Data?
    var requesting = true
    let url = URL(string: url)!
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.httpBody = body
    request.allHTTPHeaderFields = allHTTPHeaderFields
    request.timeoutInterval = timeout
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let httpResponse = response as? HTTPURLResponse {
            print("Status Code: \(httpResponse.statusCode) - \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
            guard error == nil else { print("\(error?.localizedDescription ?? "Unknown Error!") - Status Code: \(httpResponse.statusCode)"); return}
            responseData = data
            requesting = false
        }
    }
    task.resume()
    
    while requesting {
        sleep(1)
    }
    
    return responseData
}

public func httpAsync(_ url: String,
                      _ method: String = "GET",
                      _ body: Data? = nil,
                      _ allHTTPHeaderFields: [String : String]? = nil,
                      timeout: TimeInterval = 60,
                      completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ())
    -> Void {
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.allHTTPHeaderFields = allHTTPHeaderFields
        request.timeoutInterval = timeout
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            completion(data, response, error)
        }
        task.resume()
}

extension Data {

    func json<T: Codable>() -> T? {
        var decoded: T? = nil
        do {
            decoded = try customJSONDecoder().decode(T.self , from: self)
        } catch let error {
            print(error.localizedDescription)
        }
        return decoded
    }
    
    init?<T: Encodable>(encodable: T) {
        self.init(encode: encodable, with: customJSONEncoder())
    }
    
    init?<T: Encodable>(encode encodable: T, with encoder: JSONEncoder) {
        do {
            self = try encoder.encode(encodable)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}

fileprivate func customJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
        let container = try decoder.singleValueContainer()
        let dateStr = try container.decode(String.self)
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        if let date = formatter.date(from: dateStr) {
            return date
        }
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        if let date = formatter.date(from: dateStr) {
            return date
        }
        throw DecodingError.typeMismatch(Date.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode date"))
    })
    return decoder
}

fileprivate func customJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
    encoder.dateEncodingStrategy = .formatted(formatter)
    return encoder
}