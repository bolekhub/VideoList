//
//  SLRequestDispatcher.swift
//  VideoClubNO
//
//  Created by Boris Chirino on 12/9/22.
//

import Foundation

final class SLRequestDispatcher: RequestDispatcherProtocol {
     var environment: SLEnvironment
        private var networkSession: NetworkSessionProtocol
    
    required init(env: SLEnvironment, networkSession: NetworkSessionProtocol) {
        self.environment = env
        self.networkSession = networkSession
    }
    
    func execute(request: SLRequest, completion: @escaping ((SLResponse?) -> Void)) -> URLSessionTask? {
        var task: URLSessionTask?
        guard let req = request.urlRequest(environment: self.environment) else {
            return nil
        }
    
        switch request.trafficType {
        case .data:
            task = networkSession.dataTaskWithRequest(req, completion: { data, response, error in
                guard let result = data?.handleJsonResonse(response) else {
                    return
                }
                switch result {
                case let .success(response):
                    completion(response)
                case .failure(_ ):
                    completion(nil)
                }
            })
        default:
            break
        }
        task?.resume()
        return task
    }
    
}

extension Data {
    func handleJsonResonse(_ urlResponse: URLResponse?) -> Result<SLResponse, Error>{
        guard let response = urlResponse as? HTTPURLResponse else {
            return .failure(SLAPIError.invalidResponse)
        }
        
        guard 200..<300 ~= response.statusCode else {
            return .failure(SLAPIError.incorrectStatus)
        }
    
        let jsonEncoder = JSONEncoder()
        let jsonObject = try? jsonEncoder.encode(self)
        
        do {
            let json = try JSONSerialization.data(withJSONObject: jsonObject!, options: .fragmentsAllowed)
            //let result = try JSONSerialization.jsonObject(with: json, options: .fragmentsAllowed)
            return .success(ServiceResponse(data: json, code: response.statusCode))
        } catch {
            return .failure(SLAPIError.parserError)
        }
        
    }
}


struct ServiceResponse: SLResponse {
    var data: Data
    var code: Int
}

private extension Result where Success == URLResponse, Failure == Error {
    /*
    func decode<D: Decodable>(to decodable: D.Type) -> Result<D, Error> {
        switch self {
        case let .success(response):
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decoded = try decoder.decode(D.self, from: response.)
                return decoded
            } catch {
                return .failure(SLAPIError.invalidResponse)
            }
        case let .failure(error):
            return .failure(error)
    }
     */
}
