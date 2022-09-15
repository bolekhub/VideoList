//
//  DependencyDefault.swift
//  VideoClubNO
//
//  Created by Boris Chirino on 14/9/22.
//

import Foundation
import ServiceLayer

private struct RequestDispatcherKey: InjectionKey {
    static var currentValue: RequestDispatcherProtocol = SLRequestDispatcher(env: APIEnv.dev)
}

extension InjectedValues {
    var networkProvider: RequestDispatcherProtocol {
        get { Self[RequestDispatcherKey.self] }
        set { Self[RequestDispatcherKey.self] = newValue }
    }
}
