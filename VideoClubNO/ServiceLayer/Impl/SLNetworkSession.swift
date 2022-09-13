//
//  SLNetworkSession.swift
//  VideoClubNO
//
//  Created by Boris Chirino on 12/9/22.
//

import Foundation

final class SLNetworkSession: NSObject {
    var session: URLSession?
    
    typealias Handler = (progress: SLProgresHandler, completion: ((URL?, URLResponse?, Error?) -> Void)? )
    
    private var taskHandlers: [URLSessionTask: Handler] = [:]
    
    override convenience init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 20
        configuration.waitsForConnectivity = true
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        queue.qualityOfService = .userInitiated
        self.init(configuration: configuration, delegate: queue)
    }
    
    init(configuration: URLSessionConfiguration, delegate: OperationQueue) {
        super.init()
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: delegate)
    }
    
    func getHandlersForTask(_ task: URLSessionTask) -> Handler? {
        return taskHandlers[task]
    }
    
    func setHandler(handler: Handler?, for task:URLSessionTask) {
        taskHandlers[task] = handler
    }
}
