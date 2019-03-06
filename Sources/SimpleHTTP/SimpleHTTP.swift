//===------------------------------------------------------------------------------------------===//
//
// SimpleHTTP.swift
//
// A simple library to make HTTP Requests using URLRequest and Codable Data.
//
// Created by Philipp Dylong on 27.02.2019
// Copyright © 2019 Philipp Dylong. All rights reserved.
//
// See https://github.com/creekpld/SimpleHTTP
//
//===------------------------------------------------------------------------------------------===//

import Foundation

/**
    Synchronous HTTP Request
 
    - Parameters:
        - url: The URL for the request.
        - method: The HTTP request method of the receiver.
        - body: This data is sent as the message body of the request, as in an HTTP POST request.
        - allHTTPHeaderFields: A dictionary containing all the HTTP header fields of the receiver.
        - timeout: The timeout interval for the request. Defaults to 60.0 Seconds

 - Returns: The Data received by the URLRequest
**/
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

/**
 Asynchronous HTTP Request
 
 - Parameters:
 - url: The URL for the request.
 - method: The HTTP request method of the receiver.
 - body: This data is sent as the message body of the request, as in an HTTP POST request.
 - allHTTPHeaderFields: A dictionary containing all the HTTP header fields of the receiver.
 - timeout: The timeout interval for the request. Defaults to 60.0 Seconds
 - completion: The default NSURLSession completionHandler
 
 - Returns: Void
 **/
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

/**
 Data convenience routines deliver a way to Encode and Decode JSON from this Data Object
 with a custom JSONEncoder or JSONDecoder to or from a Generic Type that implements
 the Codable protocol.
 **/
extension Data {

    /**
     Data convenience method to Decode JSON Data to a Object that implements the Codable protocol.
     The Default Date Formater is set to iso8601, GMT-0, yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX
     
     Usage:
     ```
     struct YourResultModel: Codable {
        let message: String
     }
     
     let data = "{\"message\":\"Hello, World!\"}".data(using: .utf8)!
     
     let result = data.json()! as YourResultModel
     
     print(result.message) // Hello, World!
     ```
     **/
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
