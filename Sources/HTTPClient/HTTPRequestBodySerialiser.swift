//
//  File.swift
//  
//
//  Created by Rakesh Patole on 13/03/21.
//

import Foundation

public protocol HTTPRequestBodySerialiser {
    associatedtype Input : Encodable
    func serialise(_ params:Input) throws -> Data?
}

public struct JSONRequestBodySerialiser<T:Encodable> : HTTPRequestBodySerialiser {
    public typealias Input = T
    public init() {}
    public func serialise(_ params: T) throws -> Data? {
        return try JSONEncoder().encode(params)
    }
}

public struct URLEncodedRequestSerialiser : HTTPRequestBodySerialiser {
    public typealias Input = [String:String]
    public init() {}
    public func serialise(_ params: [String : String]) throws -> Data? {
        let items = params.map { URLQueryItem(name: $0, value: $1) }
        var components = URLComponents()
        components.queryItems = items
        let query = components.percentEncodedQuery
        return query?.data(using: .utf8)
    }
}
