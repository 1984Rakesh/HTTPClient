//
//  VoidEndPointDescriptor.swift
//  
//
//  Created by Rakesh Patole on 10/04/21.
//

import Foundation

public struct VoidEndPointDescriptor: EndPointDescriptor {
    public var parent: VoidEndPointDescriptor? { nil }
    public var requestBodySerialiser: URLEncodedRequestBodySerialiser? { nil }
    public func deserializeResponse(_ data: Data, response: URLResponse) throws -> AnyObject {
        throw HTTPError.genericError("Response cannot be serialised for Void End Point!!")
    }
}
