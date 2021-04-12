//
//  AnyEndPointDescriptor.swift
//  
//
//  Created by Rakesh Patole on 10/04/21.
//

import Foundation

public struct AnyEndPointDescriptor<ParentEndPointDescriptor,RequestBodySerialiser:HTTPRequestBodySerialiser,Output>: EndPointDescriptor {
    public private(set) var parent: ParentEndPointDescriptor?
    public private(set) var path: String
    public private(set) var method: HTTPMethod
    public private(set) var params: [String : String]
    public private(set) var headers: [String : String]
    public private(set) var requestBodySerialiser: RequestBodySerialiser?
    private var deserialiser: (Data,URLResponse) throws -> Output
    
    public init<Source:EndPointDescriptor>(_ source:Source) where
        ParentEndPointDescriptor == Source.ParentEndPointDescriptor,
        Output == Source.Output,
        RequestBodySerialiser == Source.RequestBodySerialiser {
        self.parent = source.parent
        self.path = source.path
        self.method = source.method
        self.params = source.params
        self.headers = source.headers
        self.requestBodySerialiser = source.requestBodySerialiser
        self.deserialiser = source.deserializeResponse
    }
    
    public func deserializeResponse(_ data: Data, response: URLResponse) throws -> Output {
        return try self.deserialiser(data, response)
    }
}

public extension EndPointDescriptor {
    func eraseToAnyEndPointDescriptor() -> AnyEndPointDescriptor<ParentEndPointDescriptor,RequestBodySerialiser,Output> {
        return AnyEndPointDescriptor(self);
    }
}
