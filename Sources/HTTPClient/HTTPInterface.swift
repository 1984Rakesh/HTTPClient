import Foundation
import Combine

extension Publisher {
    public func sinkResult(_ subscriber: @escaping (Result<Output,Error>) -> Void) -> AnyCancellable {
        return sink(
            receiveCompletion: { result in
                switch result {
                case .failure(let error): subscriber(Result.failure(error))
                case .finished: break
                }
            },
            receiveValue: { output in
                subscriber(Result.success(output))
            }
        )
    }
}

public enum HTTPError: Error {
    case noResponse
    case responseDeserialiseError(error: Error)
    case requestSerialiseError(String)
    case networkError(error: Error)
    case genericError(String)
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

//protocol Model : Codable, Identifiable, Hashable {
//}

public protocol HTTPInterface: class {
    var baseURL : URL! { get }
    var host : URL! { get }
    var defaultHeaders : [String:String]? { get set }
    var defaultURLParams: [String: String]? { get set }
    
    func headers<T:EndPointDescriptor>(_ endPoint:T) -> [String:String]
    func urlParams<T:EndPointDescriptor>(_ endPoint:T) -> [String:String]?
    func call<T:EndPointDescriptor>(endPoint:T) -> AnyPublisher<T.Output,HTTPError>
}

public extension HTTPInterface {
    func headers<T:EndPointDescriptor>(_ endPoint:T) -> [String:String] {
        return ["Origin":self.host.absoluteString,
                "Content-Type":endPoint.requestBodySerialiser?.contentType ?? HTTPContentType.none.rawValue]
            .merging(self.defaultHeaders ?? [:], uniquingKeysWith: { $1 })
            .merging(endPoint.headers, uniquingKeysWith: { $1 })
    }
    
    func urlParams<T:EndPointDescriptor>(_ endPoint:T) -> [String:String]? {
        return [String:String]()
            .merging( self.defaultURLParams ?? [:], uniquingKeysWith: { $1 })
            .merging( endPoint.params , uniquingKeysWith: { $1 })         
    }
    
    func request<T:EndPointDescriptor>(endPoint:T) -> AnyPublisher<URLRequest,HTTPError> {
        return Future <URLRequest,HTTPError> { [weak self]  promise in
            do {
                let request = try URLRequest(baseURL: self?.baseURL ?? URL(string: "http://")!)
                    .method(endPoint.method)
                    .path(endPoint.path)
                    .params(self?.urlParams(endPoint) ?? [:])
                    .headers(self?.headers(endPoint) ?? [:])
                    .body(endPoint.requestBodySerialiser?.serialise())
                             
                promise(.success(request))
            }
            catch {
                promise(.failure(HTTPError.networkError(error:error)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func call<T:EndPointDescriptor>(endPoint:T) -> AnyPublisher<T.Output,HTTPError>{
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
