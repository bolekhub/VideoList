//
//  Protocols.swift
//  VideoClubNO
//
//  Created by Boris Chirino on 12/9/22.
//

import Foundation

/*
protocol SLRequestProtocol {
    var method: SLHTTPMethod { get }
    var url: URL { get }
    var headers: [String: String] { get }
    var body: Data { get }
    var sessionType: SLRequestType { get set }
}
 
extension SLRequestProtocol {
     func request(_ request: SLRequest, environment: SLEnvironment) throws -> URLRequest? {
         guard let url = URL(string: environment.baseURL) else {
             throw SLAPIError.badURL
         }
         var urlRequest = URLRequest(url: url,
                                     cachePolicy: .useProtocolCachePolicy,
                                     timeoutInterval: environment.timeout)
         request.headers.forEach { key, value in
             urlRequest.addValue(value, forHTTPHeaderField: key.rawValue)
         }
         urlRequest.httpBody = request.body
         urlRequest.httpMethod = request.method.rawValue
         urlRequest.url = URL(string: request.url)
         return urlRequest
     }
 }

*/

protocol SLResponse {
    var data: Data { get }
    var code: Int { get }
}

protocol SLEnvironment {
    var headers: [String: String] { get }
    var baseURL: String { get }
    var timeout: TimeInterval { get }
}

protocol SLOperationProtocol {
    associatedtype Output
    
    var request: SLRequest { get }
    func execute(in requestDispatcher: RequestDispatcherProtocol, completion: @escaping (Output) -> Void) -> Void
    func cancel() -> Void
}

protocol RequestDispatcherProtocol {
    var environment: SLEnvironment { get }
    init(env: SLEnvironment, networkSession: NetworkSessionProtocol)
    func execute(request: SLRequest, completion: @escaping ((SLResponse?) -> Void)) -> URLSessionTask?
}


protocol NetworkSessionProtocol {
    func dataTaskWithRequest(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask?
    
    func downloadTaskWithRequest(_ request: URLRequest, progress: SLProgresHandler,  completion: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask?

}

