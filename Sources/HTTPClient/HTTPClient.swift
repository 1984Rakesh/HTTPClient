import Foundation
import Combine

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
    case none = ""
}

public protocol HTTPClient {
    var baseURL : URL! { get }
    var host : URL! { get }
    var additionalHeaders : [String:String]? { get set }
}

open class BaseHTTPClient : HTTPClient {
    public var baseURL: URL!    
    public var host: URL!
    public var additionalHeaders: [String : String]?
    
    public init(baseURL:URL) {
        self.baseURL = baseURL
        self.host = baseURL
    }
    
    open func headers<T:EndPointDescriptor>(endPoint:T) -> [String:String] {
        return ["Origin":self.host.absoluteString,
                "Content-Type":endPoint.requestBodySerialiser?.contentType ?? HTTPContentType.none.rawValue]
            .merging(self.additionalHeaders ?? [:], uniquingKeysWith:{ $1 })
            .merging(endPoint.headers, uniquingKeysWith:{ $1 })
    }
    
    open func request<T:EndPointDescriptor>(endPoint:T) -> AnyPublisher<URLRequest,HTTPError> {
        return Future <URLRequest,HTTPError> { [weak self]  promise in
            do {
                let request = try URLRequest(baseURL: self?.baseURL ?? URL(string: "http://")!)
                    .method(endPoint.method)
                    .path(endPoint.path)
                    .params(endPoint.params)
                    .headers(self?.headers(endPoint: endPoint) ?? [:])
                    .body(endPoint.requestBodySerialiser?.serialise())
                             
                promise(.success(request))
            }
            catch {
                promise(.failure(HTTPError.networkError(error:error)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    open func call<T:EndPointDescriptor>(endPoint:T) -> AnyPublisher<T.Output,HTTPError>{
        request(endPoint: endPoint)
            .flatMap {
                URLSession.shared
                    .dataTaskPublisher(for: $0)
                    .tryMap { try endPoint.deserializeResponse($0, response: $1)}
                    .mapError { HTTPError.networkError(error: $0) }
                    .receive(on: DispatchQueue.main)
            }
            .eraseToAnyPublisher()
    }
}
