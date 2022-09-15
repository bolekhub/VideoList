//
//  Environment.swift
//  VideoClubNO
//
//  Created by Boris Chirino on 14/9/22.
//

import Foundation
import ServiceLayer

enum APIEnv: SLEnvironmentProtocol {
    case dev
    case pro
    
    var headers: [String : String] {
        switch self {
        case .dev:
           return ["Client": "Demo"]
        case .pro:
            return [:]
        }
    }
    
    var baseURL: String {
        switch self {
        case .dev:
            return "https://gist.githubusercontent.com/deepakpk009/99fd994da714996b296f11c3c371d5ee/raw/28c4094ae48892efb71d5122c1fd72904088439b/"
        case .pro:
            return "https://api.example.com/v1/"
        }
    }
    
    var timeout: TimeInterval {
        switch self {
        case .pro:
            return 10
        case .dev:
            return 40
        }
    }
}
