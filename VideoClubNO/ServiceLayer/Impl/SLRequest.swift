//
//  Request.swift
//  VideoClubNO
//
//  Created by Boris Chirino on 12/9/22.
//

import Foundation

protocol RequestProtocol {
    var path: String { get }
    var method: RequestMethod { get }
    var headers: ReaquestHeaders? { get }
    var parameters: RequestParameters? { get }
    var requestType: RequestType { get }
    var responseType: ResponseType { get }
    var progressHandler: ProgressHandler? { get set }
    
}

struct SLRequest {
    private let jsonEncoder = JSONEncoder()
    var requestType: SLParameterType
    var method: SLHTTPMethod
    var url: String = ""
    var headers: [SLHeaderField: String] = [:]
    var body: Data? = nil
    var trafficType: SLRequestType = .data
    var path: String? = nil
}


extension SLRequest {
    
    init(requestType: SLParameterType, url: String, method: SLHTTPMethod = .GET, path: String?) {
        self.path = path
        self.requestType = requestType
        self.url = url
        self.method = method
        
        switch requestType {
        case .requestURL(let requestParams):
            if requestParams.keys.count > 0, let resolveURL = URL(string: self.url) {
                var components = URLComponents(url: resolveURL, resolvingAgainstBaseURL: true)
                components?.queryItems = requestParams.map({ key, value in
                    return URLQueryItem(name: key, value: String(describing: value))
                })
                self.url = components?.url?.description ?? ""
            }
            self.method = method
            
        case .body(let enconding):
        switch enconding {
            case let .json(param):
                guard let encodedParam = param.encodeObject() else { return }
                self.body = encodedParam.data(using: .utf8, allowLossyConversion: true)
                self.headers = enconding.headerValue
                self.method = .POST
                
            case let .urlencoded(param):
                if param.keys.count > 0, let resolveURL = URL(string: self.url) {
                    var components = URLComponents(url: resolveURL, resolvingAgainstBaseURL: false)
                    components?.queryItems = param.map({ key, value in
                        return URLQueryItem(name: key, value: String(describing: value))
                    })
                    self.body = components?.query?.data(using: .utf8, allowLossyConversion: true)
                }
                self.headers = enconding.headerValue
                self.method = .POST
                
            case let .formdata(parameters):
                let bodyString = self.formDataFromParameters(parameters)
                self.body = bodyString.data(using: .utf8)
                self.headers = enconding.headerValue
                self.method = .POST
            }
        }
    }
}

extension SLRequest {
    func debugPrint() {
        print("Headers: \(headers.mapValues({$0}))")
        
        if let bodyo = self.body, let str = String(data: bodyo, encoding: .utf8) {
            print("Body : \n \(str) \n")
        }
        print("URL: \(self.url)")
    }
    
    func formDataFromParameters(_ parameters: [String: Any]) -> String {
        var stringBody: String = ""
        let boundary = "Boundary-\(UUID().uuidString)"
        for parameter in parameters {
            stringBody += "--\(boundary)\r\n"
            stringBody += "Content-Disposition:form-data; name=\"\(parameter.key)\""
            if type(of: parameter.value) == Data.self {
                let fileContent = String(data: parameter.value as! Data, encoding: .utf8)!
                stringBody += "; filename=\"\(parameter.key)\"\r\n"
                + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
            } else {
                let value = String(describing: parameter.value)
                stringBody += "\r\n\r\n\(value)\r\n"
            }
        }
        return stringBody
    }
}

extension SLRequest {
    func urlRequest(environment: SLEnvironment) -> URLRequest? {
        guard let url = URL(string: environment.baseURL) else {
            return nil
        }
        let fullUrl = url.appendingPathComponent(self.path)
        var urlRequest = URLRequest(url: fullUrl,
                                    cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: environment.timeout)
        self.headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key.rawValue)
        }
        urlRequest.httpBody = self.body
        urlRequest.httpMethod = self.method.rawValue
        urlRequest.url = URL(string: self.url)
        return urlRequest
    }
    
    mutating func setBaseURL(_ url: String) {
        self.url = url
    }
}

extension Encodable {
    func encodeObject() -> String? {
        let data = try? JSONEncoder().encode(self)
        return data.flatMap({ String(data: $0, encoding: .utf8) })

    }
}
