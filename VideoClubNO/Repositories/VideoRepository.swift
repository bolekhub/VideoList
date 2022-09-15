//
//  VideoRepository.swift
//  VideoClubNO
//
//  Created by Boris Chirino on 14/9/22.
//

import Foundation
import ModelLibrary
import ServiceLayer
import Combine

protocol VideoRepositoryProtocol {
    func getVideos(_ completion: @escaping ([VideoSourceItemRepresentable]?) -> Void )
    func getVideos() -> Future<[VideoSourceItemRepresentable]?, Never>
}

struct VideoRepository: VideoRepositoryProtocol {
    @Injected(\.networkProvider) private var dispatcher: RequestDispatcherProtocol

    var environment: SLEnvironmentProtocol?
    var response: SLResponseProtocol?
    
    func getVideos(_ completion: @escaping ([VideoSourceItemRepresentable]?) -> Void) {
        let request = SLRequest(requestType: .requestURL([:]), serviceName: "media.json")
        let operation = SLOperation(request)
        operation.execute(in: dispatcher) { response in
            do {
                let decoder = try JSONDecoder().decode(Catalog.self, from: response!.data)
                let result = decoder.categories.first?.videos
                completion(result)
            } catch {
                
            }
        }
    }
    
    //with combine we can transform our closure code into usable combine code. This is a great step, one team can go modernizing presentation and others data for ex. in the mean while this is a intermediate approach.
    func getVideos() -> Future<[VideoSourceItemRepresentable]?, Never> {
        let request = SLRequest(requestType: .requestURL([:]), serviceName: "media.json")
        let operation = SLOperation(request)
        return Future() { promise in
            operation.execute(in: dispatcher) { response in
                let decoder = try? JSONDecoder().decode(Catalog.self, from: response!.data)
                let result = decoder?.categories.first?.videos
                promise(Result.success(result))
            }
        }
    }
}
