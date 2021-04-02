//
//  File.swift
//
//
//  Created by Rakesh Patole on 13/03/21.
//

import Foundation

public protocol HTTPRequestBodySerialiser {
    associatedtype Input : Encodable
    typealias SerialiserFunction = () throws -> Input
    var serialiser : SerialiserFunction { get }
    var contentType : String { get }
    init(serialiser:@escaping SerialiserFunction)
    func serialise() throws -> Data?
}

public struct JSONRequestBodySerialiser<T:Encodable> : HTTPRequestBodySerialiser {
    public typealias Input = T
    public var contentType: String {  HTTPContentType.json.rawValue }
    public var serialiser: SerialiserFunction
    
    public init(serialiser:@escaping SerialiserFunction) {
        self.serialiser = serialiser
    }

    public func serialise() throws -> Data? {
        let param : T = try serialiser()
        return try JSONEncoder().encode(param)
    }
}

public struct URLEncodedRequestBodySerialiser : HTTPRequestBodySerialiser {
    public typealias Input = [String:String]
    public var contentType: String {  HTTPContentType.urlEncoded.rawValue }
    public var serialiser: SerialiserFunction
    
    public init(serialiser:@escaping SerialiserFunction) {
        self.serialiser = serialiser
    }
    
    public func serialise() throws -> Data? {
        let params = try serialiser()
        let items = params.map { URLQueryItem(name: $0, value: $1) }
        var components = URLComponents()
        components.queryItems = items
        let query = components.percentEncodedQuery
        return query?.data(using: .utf8)
    }
}
