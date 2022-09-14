//
//  Protocols.swift
//  VideoClubNO
//
//  Created by Boris Chirino on 12/9/22.
//

import Foundation

protocol SLResponseProtocol {
    var data: Data { get }
    var code: Int { get }
    var headers: [AnyHashable: Any]? { get }
    var body: String? { get }
    var bodyRepresentation: NSDictionary? { get }
}

extension SLResponseProtocol {
    var body: String? {
        String(data: data, encoding: .utf8)
    }
    
    var bodyRepresentation: NSDictionary? {
        let json = try? JSONSerialization.jsonObject(with: self.data, options: .fragmentsAllowed)
        return json as? NSDictionary
    }
}

protocol SLEnvironmentProtocol {
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
    var environment: SLEnvironmentProtocol { get }
    init(env: SLEnvironmentProtocol, networkSession: NetworkSessionProtocol)
    func execute(request: SLRequest, completion: @escaping ((SLResponseProtocol?) -> Void)) -> URLSessionTask?
}


protocol NetworkSessionProtocol {
    func dataTaskWithRequest(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask?
    
    func downloadTaskWithRequest(_ request: URLRequest, progress: SLProgresHandler?,  completion: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask?
}

