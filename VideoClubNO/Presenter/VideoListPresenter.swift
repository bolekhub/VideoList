//
//  VideoListPresenter.swift
//  VideoClubNO
//
//  Created by Boris Chirino on 14/9/22.
//

import Foundation
import Combine

protocol VideoPresenterProtocol {
    var viewProtocol: ViewControllerProtocol? { get set }
    func fetchVideos()
}

final class VideoPresenter {
    let videoRepository = VideoRepository()
    weak var viewProtocol: ViewControllerProtocol?
    var subscriptions = Set<AnyCancellable>()
}

extension VideoPresenter: VideoPresenterProtocol {
    func fetchVideos() {
        videoRepository.getVideos()
            .flatMap { representableArray -> AnyPublisher<[VideoSourceItem]?, Never> in
                let hunt = representableArray?.compactMap({ representableItem in
                    return VideoSourceItem(representable: representableItem)
                })
                return Just(hunt).eraseToAnyPublisher()
            }
            .compactMap{$0}
            .sink { videoItems in
                self.viewProtocol?.videoSubject.send(videoItems)
            }.store(in: &subscriptions)
    }
}
