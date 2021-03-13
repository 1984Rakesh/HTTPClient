import Foundation

public enum HTTPError: Error {
    case noResponse
    case responseDeserialiseError(error: Error)
    case requestSerialiseError(String)
    case networkError(error: Error)
}

public enum HTTPMethod : String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum HTTPContentType : String {
    case urlEncoded = "application/x-www-form-urlencoded"
    case json = "application/json"
}

public protocol HTTPClient {
    var baseURL : URL { get }
    var host : URL { get }
}
