//
//  Model.swift
//  VideoClubNO
//
//  Created by Boris Chirino on 14/9/22.
//

import ModelLibrary
import Foundation

struct Catalog: Codable {
    private let cats: [Category]

    enum CodingKeys: String, CodingKey {
        case cats = "categories"
    }
}

extension Catalog: CatalogRepresentable {
    var categories: [CategoryRepresentable] {
        cats
    }
}

struct Category: Codable {
    let name: String
    private let vid: [VideoSourceItem]
    
    enum CodingKeys: String, CodingKey {
        case name
        case vid = "videos"
    }
}

extension Category: CategoryRepresentable {
    var videos: [VideoSourceItemRepresentable] {
        vid
    }
}


struct VideoSourceItem: Codable, VideoSourceItemRepresentable {
    let thumbnail: String
    let title: String
    let subtitle: String
    let description: String
    let sources:[String]
    let uid = UUID()

    enum CodingKeys: String, CodingKey {
        case thumbnail = "thumb"
        case title
        case subtitle
        case description
        case sources
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let thumbUrl = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        self.thumbnail = thumbUrl?.asSecureURL() ?? ""
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle) ?? ""
        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        let unsecureSources = try container.decodeIfPresent([String].self, forKey: .sources) ?? []
        var securedSources: [String] = []
        _ = unsecureSources.reduce(into: securedSources) { _, element in
            let securedUrl = element.asSecureURL()
            securedSources.append(securedUrl, conditionedBy: securedUrl != nil)
        }
        self.sources = securedSources
    }
    
    init(representable: VideoSourceItemRepresentable) {
        self.thumbnail = representable.thumbnail
        self.title = representable.title
        self.subtitle = representable.subtitle
        self.description = representable.description
        self.sources = representable.sources
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
        hasher.combine(thumbnail)
        hasher.combine(title)
    }
    
    static func == (lhs: VideoSourceItem, rhs: VideoSourceItem) -> Bool {
        return lhs.uid == rhs.uid &&
               lhs.thumbnail == rhs.thumbnail &&
               lhs.title == rhs.title
    }
}

extension VideoSourceItem: Hashable {
    
}
