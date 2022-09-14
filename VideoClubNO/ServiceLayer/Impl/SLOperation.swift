//
//  SLOperation.swift
//  VideoClubNO
//
//  Created by Boris Chirino on 12/9/22.
//

import Foundation

final class SLOperation: SLOperationProtocol {
    typealias Output = SLResponseProtocol?
    private var task: URLSessionTask?
    var request: SLRequest
    
    init(_ request: SLRequest) {
        self.request = request
    }
    
    func cancel() {
        task?.cancel()
    }

    func execute(in requestDispatcher: RequestDispatcherProtocol, completion: @escaping (SLResponseProtocol?) -> Void) {
        let baseUrl = requestDispatcher.environment.baseURL
        self.request.setBaseURL(baseUrl)
        task = requestDispatcher.execute(request: request, completion: { result in
            completion(result)
        })
    } 
}
