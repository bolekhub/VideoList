//
//  SLNetworkSession+Extension.swift
//  VideoClubNO
//
//  Created by Boris Chirino on 12/9/22.
//

import Foundation
extension SLNetworkSession: NetworkSessionProtocol {
    func dataTaskWithRequest(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask? {
        let task = session?.dataTask(with: request, completionHandler: completion)
        return task
    }
    //     typealias Handler = (progress: SLProgresHandler, completion: ((URL?, URLResponse?, Error?) -> Void)? )

    func downloadTaskWithRequest(_ request: URLRequest, progress: SLProgresHandler, completion: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask? {
        let downloadTask = session?.downloadTask(with: request)
//        setHandler(handler: (progress, completion), for: downloadTask)
        return downloadTask
    }
}

extension SLNetworkSession: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        guard let handlers = getHandlersForTask(task) else { return }
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        DispatchQueue.main.async {
            handlers.progress(progress)
        }
        self.setHandler(handler: nil, for: task)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloadTask = task as? URLSessionDownloadTask,
              let handler = getHandlersForTask(task) else {
                  return
              }
            //TODO: handle download
    }
}
