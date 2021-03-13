//
//  File.swift
//  
//
//  Created by Rakesh Patole on 13/03/21.
//

import Foundation

public protocol EndPointDescriptor {
    associatedtype Output
    var path : String { get }
    var method : HTTPMethod { get }
    var params : [String:String] { get }
    var headers : [String:String] { get }
    var contentType : String { get }
    
    func body() throws -> Data?
    func deserializeResponse(_ data:Data, response:URLResponse) throws -> Output
}

public extension EndPointDescriptor {
    var method : HTTPMethod { .get }
    var params : [String:String] { [:] }
    var headers : [String:String] { [:] }
}
