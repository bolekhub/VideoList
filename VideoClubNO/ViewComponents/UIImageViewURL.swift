//
//  UIImageViewURL.swift
//  VideoClubNO
//
//  Created by Boris Chirino on 15/9/22.
//

import Foundation
import Combine
import UIKit

let imageCache = ImageCache.shared

enum APIError: Error {
    case unknown
    case sessionError(reason: String)
}

final class UIImageViewURL: UIImageView {
    private var subscriptions = Set<AnyCancellable>()
    private var imageDataSubject = PassthroughSubject<Data, Never>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func loadImageFromURL(url: String) {
        guard let finalURL = URL(string: url) else { return }
        self.getFromUrl(finalURL)
            .sink { _ in } receiveValue: { [weak self] data in
                self?.imageDataSubject.send(data)
            }.store(in: &subscriptions)
    }
    
    deinit {
        subscriptions.removeAll()
    }
}

private extension UIImageViewURL {
    func getFromUrl(_ url: URL)  -> AnyPublisher<Data, Error> {
        if let imageData = imageCache[url.absoluteString] {
            return Just(imageData as Data)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else { throw APIError.unknown }
                imageCache[url.absoluteString] = NSData(data: data)
                return data
            }
            .mapError { error in
                if let error = error as? APIError {
                    return error
                } else {
                    return APIError.sessionError(reason: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func commonInit() {
        imageDataSubject
            .flatMap { data -> AnyPublisher<UIImage?, Never> in
                guard let image = UIImage(data: data) else {
                    return Empty().eraseToAnyPublisher()
                }
                return Just(image).eraseToAnyPublisher()
            }
            .compactMap{$0}
            //.receive(on: RunLoop.main)
            // .assign(to: \.image, on: self)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
            //.sink(receiveValue: { image in
            //    self.image = image
            //})
            .store(in: &subscriptions)
    }
}
