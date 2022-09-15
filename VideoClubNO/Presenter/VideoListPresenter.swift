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
            .compactMap{$0}
            .sink { items in
                self.viewProtocol?.didReceive(videos: items)
            }.store(in: &subscriptions)
    }
}
