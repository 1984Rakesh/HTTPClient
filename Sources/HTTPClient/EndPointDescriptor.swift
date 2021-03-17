//
//  File.swift
//  
//
//  Created by Rakesh Patole on 13/03/21.
//

import Foundation

public protocol EndPointDescriptor {
    associatedtype RequestBodySerialiser : HTTPRequestBodySerialiser
    associatedtype Output
    var path : String { get }
    var method : HTTPMethod { get }
    var params : [String:String] { get }
    var headers : [String:String] { get }
    var requestBodySerialiser : RequestBodySerialiser? { get}
    func deserializeResponse(_ data:Data, response:URLResponse) throws -> Output
}

public extension EndPointDescriptor {
    var method : HTTPMethod { .get }
    var params : [String:String] { [:] }
    var headers : [String:String] { [:] }
}
