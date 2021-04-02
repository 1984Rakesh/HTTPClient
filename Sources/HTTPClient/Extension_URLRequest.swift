//
//  File.swift
//
//
//  Created by Rakesh Patole on 13/03/21.
//

import Foundation

public extension URLRequest {
    init(baseURL:URL){
        self.init(url: baseURL)
    }
    
    private var components : URLComponents? {
        return URLComponents(url: self.url!, resolvingAgainstBaseURL: true)
    }
    
    private func updateComponents(_ components:URLComponents?) throws -> URLRequest {
        var _request = self
        guard let url = components?.url else {
            throw HTTPError.requestSerialiseError("Invalid URL Components!!")
        }
        _request.url = url
        return _request
    }
    
    func method(_ method:HTTPMethod) -> URLRequest {
        var _request = self
        _request.httpMethod = method.rawValue
        return _request
    }
    
    func path(_ path:String) throws -> URLRequest {
        guard path.count > 0 else {
            return self
        }
        
        var urlComponents = self.components
        urlComponents?.path = path
        return try updateComponents(urlComponents)
    }
    
    func params(_ params:[String:String]) throws -> URLRequest {
        let items = params.map { URLQueryItem(name: $0, value: $1) }
        var urlComponents = self.components
        urlComponents?.queryItems = items
        return try updateComponents(urlComponents)
    }
    
    func headers(_ headers:[String:String]) -> URLRequest {
        var _request = self
        for (key, value) in headers {
            _request.setValue(value, forHTTPHeaderField: key)
        }
        return _request
    }
    
    func body(_ body:Data?) -> URLRequest {
        var _request = self
        _request.httpBody = body
        return _request
    }
}
