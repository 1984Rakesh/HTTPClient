//
//  File.swift
//  
//
//  Created by Rakesh Patole on 13/03/21.
//

import Foundation

public protocol HTTPResponseDeserialiser {
    associatedtype Output : Decodable
    func deserialise(_ data:Data,_ response:URLResponse) throws -> Output
}

public struct JSONResponseDeserialiser<T:Decodable> : HTTPResponseDeserialiser {
    public typealias Output = T
    
    public init() {}
    
    public func deserialise(_ data:Data,_ response:URLResponse) throws -> T {
        guard data.count != 0 else { throw HTTPError.noResponse }
        do { return try JSONDecoder().decode(T.self, from: data) }
        catch { throw HTTPError.responseDeserialiseError(error: error) }
    }
}
